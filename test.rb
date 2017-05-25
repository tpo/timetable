#!/usr/bin/ruby
require_relative 'timetable'
require 'minitest/autorun'
require 'pry'
require 'pry-byebug'
 
require 'active_support'
require 'active_support/core_ext' # Time.now + 1.minute

# http://blog.teamtreehouse.com/short-introduction-minitest
#
class TestTimetable < Minitest::Test
 
  def test_inserted_appointments_have_correct_order
    timetable=Timetable.new()

    a1 = Appointment.new(title: "a1", start: DateTime.parse("2017-05-01 17:05:00"))
    a2 = Appointment.new(title: "a2", start: DateTime.parse("2017-04-28 17:05:00"))
    a3 = Appointment.new(title: "a3", start: DateTime.parse("2017-05-14 17:05:00"))
    a4 = Appointment.new(title: "a4", start: DateTime.parse("2017-05-12 17:05:00"))

    timetable << a1
    timetable << a2
    timetable << a3
    timetable << a4

    # timetable.dump

    assert_equal(timetable[0], a2)
    assert_equal(timetable[1], a1)
    assert_equal(timetable[2], a4)
    assert_equal(timetable[3], a3)
  end
 
  def test_raises_overlap_with_previous_appointment
    timetable=Timetable.new()

    a1 = Appointment.new(title: "a1", start: DateTime.parse("2016-12-15 17:05:00"), duration: 2.hours)
    a2 = Appointment.new(title: "a2", start: DateTime.parse("2016-12-15 17:06:00"))

    timetable << a1
    assert_raises(Overlap) { timetable << a2 }
  end
 
  def test_raises_overlap_with_later_appointment
    timetable=Timetable.new()

    a1 = Appointment.new(title: "a1", start: DateTime.parse("2016-12-15 17:06:00"))
    a2 = Appointment.new(title: "a2", start: DateTime.parse("2016-12-15 17:05:00"), duration: 2.hours)

    timetable << a1
    assert_raises(Overlap) { timetable << a2 }
  end
 
  def test_overlap_error_includes_involvements
    timetable=Timetable.new()

    a1 = Appointment.new(title: "a1", start: DateTime.parse("2016-12-15 17:05:00"), duration: 2.hours)
    a2 = Appointment.new(title: "a2", start: DateTime.parse("2016-12-15 17:06:00"))

    timetable << a1
    
    begin
      timetable << a2
    rescue => err
      assert_equal(a1,err.involvement_a)
      assert_equal(a2,err.involvement_b)
    end
  end
 
  def test_overlap_error_includes_involvements
    timetable=Timetable.new()

    a1 = Appointment.new(title: "a1", start: DateTime.parse("2016-12-15 17:05:00"), duration: 2.hours)
    a2 = Appointment.new(title: "a2", start: DateTime.parse("2016-12-15 17:06:00"))

    timetable << a1
    
    begin
      timetable << a2
    rescue => err
      assert_equal(a1,err.involvement_a)
      assert_equal(a2,err.involvement_b)
    end
  end
end
 
require_relative 'appointments'

class TestAppointment < Minitest::Test
  def test_dailyappointments_are_separated_by_one_day
    a = DailyAppointment.new(title: "a1", start: DateTime.parse("2016-12-15 17:05:00"))
    
    sequence_no = 0
    previous_appointment = a
    a.each do |new_appointment|
      sequence_no += 1
      # assume that we have verified, that EventGenerator works
      # after the 3rd iteration:
      break if sequence_no == 4 
      assert_equal(previous_appointment.start + 1.day, new_appointment.start)
      previous_appointment = new_appointment
    end
  end
end
