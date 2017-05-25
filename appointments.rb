require_relative 'timetable'

class DailyAppointment < Appointment

  include EventGenerator

  def next_start(event)
    event.start + 1.day
  end
end
