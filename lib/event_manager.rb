require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone_num)
  phone_num = phone_num.to_s
  phone_num.gsub!('-', '')
  phone_num.gsub!(' ', '')
  phone_num.gsub!('.', '')
  phone_num.gsub!('(', '')
  phone_num.gsub!(')', '')

  phone_num = phone_num[1..-1] if (phone_num.length == 11) && (phone_num[0] == '1') 
  return 'Bad Phone Number' unless phone_num.length == 10
  phone_num
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

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

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  
  phone = clean_phone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  puts "#{id}: #{phone}"

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end



p common_days(contents)
p common_times(contents)