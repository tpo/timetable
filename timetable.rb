#!/usr/bin/ruby
#
# requires Ruby > 2.1 because 'required named parameters' is a 2.1 feature

# Concept:
# * Events of different kinds are inserted into the Timetable,
# * but the final result is a SortedArray of plain Events where
# * each event has a 'start' and a 'duration' and
# * that's it

require 'date' # DateTime
require 'pp'
require 'active_support'
require 'active_support/core_ext' # DateTime.now + 1.minute

# An Event is a fundamental entry in a Timetable
# that has a 'start' date and a 'duration',
# a title and a description.
#
# In the case when an Event has been generated from
# something else - say from a Task that has been
# divided into smaller work portions, that the Event
# points to that 'source' from which it was created.
#
class Event
  attr_accessor :title,
                :start,
                :duration,
                :description,
                :source

  def initialize( title:,
                  start:,
                  duration:    0.minutes,
                  description: "",
                  source:      nil)

      @title       = title
      @start       = start
      @duration    = duration
      @description = description
      @source      = source
  end

  def end_
      @start + duration
  end

  def can_conflict
      false
  end
end

class Involvement < Event
  attr_accessor :has_conflict

  def initialize( title:,
                  start:       nil,
                  duration:    10.minutes,
                  description: "")

      super(title:       title,
            start:       start,
            duration:    duration,
            description: description)

      @has_conflict    = false
  end

  def can_conflict
      true
  end
end

class Appointment < Involvement
  def initialize( title:,
                  start:,
                  duration:    10.minutes,
                  description: "")

      super(title:       title,
            start:       start,
            duration:    duration,
            description: description)
  end
end

class Task < Involvement
  def initialize( title:,
                  duration:    10.minutes,
                  prio:        2,
                  deadline:    nil,
                  description: "")

      super(title:       title,
            start:       Time.now,
            duration:    duration,
            description: description)

      @prio            = prio
      @deadline        = deadline
  end
end

class Overlap < RuntimeError
  attr_reader :involvement_a,:involvement_b

  def initialize( involvement_a, involvement_b )
      super("Overlap between two involvement's")
      @involvement_a = involvement_a
      @involvement_b = involvement_b
  end
end

# Ideas:
# * create SortedArray that uses bsearch O(log n) to insert
# 
class Timetable

  def initialize(horizon="2years")
      @involvements=[] # sorted array!
      @horizon=horizon
  end

  # can raise Overlap via insert
  def <<(involvement)
      # print "inserting:\n"
      # pp involvement.dump

      inserted = false
      @involvements.each_index { |i|
          # insert involvement before the first involvement that comes later
          if @involvements[i].start > involvement.start
              # can raise exception
              insert(i,involvement)
              inserted = true
              break
          end
      }
      if ! inserted
          # add to the end
          insert(@involvements.length,involvement)
      end

      # print "terminplan:\n"
      # self.dump
  end

  def each(&block)
      @involvements.each(&block)
  end

  def [](index)
      @involvements[index]
  end

  def dump()
      @involvements.each { |involvement|
          pp involvement.dump
      }
  end

  private
    def note_conflict(earlier_involvement, later_involvement)
       if earlier_involvement.end_ > later_involvement.start
         later_involvement.has_conflict = true

         raise Overlap.new(earlier_involvement, later_involvement)
       else
         later_involvement.has_conflict = false
       end
    end

    # can raise "Overlap" via note_conflict
    def insert(i, new_involvement)
        later_involvement = @involvements[i]
        if i > 0
           previous_involvement = @involvements[i-1]
        else
           previous_involvement = nil
        end

        @involvements.insert(i,new_involvement)

        if later_involvement != nil
            note_conflict(new_involvement,later_involvement)
        else
            # we're inserting at the end of the array
        end

        if previous_involvement != nil
            note_conflict(previous_involvement,new_involvement)
        else
            # we're inserting at the beginning of the array
        end
    end
end
