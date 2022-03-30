require 'csv'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def common_times(csv)
  csv.rewind
  csv.reduce(Hash.new(0)) do |times, row|
    time = DateTime.strptime(row[:regdate], '%m/%d/%y %k:%M')
    times[time.hour] += 1
    times
  end
end

def common_days(csv)
  csv.rewind
  csv.reduce(Hash.new(0)) do |data, row|
    time = DateTime.strptime(row[:regdate], '%m/%d/%y %k:%M')
    data[time.to_date.wday] += 1
    data
  end
end


STDOUT.puts common_times(contents).inspect
STDOUT.puts common_days(contents).inspect
