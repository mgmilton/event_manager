require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phone_number)
    phone_number.delete("-").delete("(").delete(")").delete(".").delete(" ")
    case phone_number.length
    when 10 then phone_number
    when 11
      if phone_number[0] == "1"
        phone_number[1..10]
      else
        "Number is Bad"
      end
    else
      "Number is Bad"
    end
end

def date_time_parser(regdate)
  require 'pry' ; binding.pry
  date = DateTime.new(regdate)
  date.strptime("%Y-%m-%dT%H:%M:%S")
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


puts "EventManager initialized"
contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phonenumber = clean_phone_numbers(row[:homephone])
  regdate = date_time_parser(row[:regdate])
  p "#{regdate}"
  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_template.result(binding)
  #save_thank_you_letters(id, form_letter)
end
