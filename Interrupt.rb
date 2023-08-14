require 'nokogiri' # Require gem nokogiri to read XML files

# In game folder, Data/Localization/English.pak must be unpacked (LSLib Toolkit for example)
# Then convert Localization\English\english.loca to english.xml
file = File.open('english.xml', "r:UTF-8", &:read)
xml_localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# XXX_pak is the folder where I unpacked XXX.pak
file1 = 'E:\BG3_Unpack\Shared_pak\Public\Shared\Stats\Generated\Data\Interrupt.txt'
file2 = 'E:\BG3_Unpack\Shared_pak\Public\SharedDev\Stats\Generated\Data\Interrupt.txt'

# Redirect output to a file instead of the console
$stdout = File.new( './Interrupt.txt', 'w' )

puts "=====  Parsing start   ====="
puts ""

# Parse the localization, create an hash: loca[UID] = human readable text
loca = {}
xml_localization.xpath('/contentList/content').each do |item|
    loca[item["contentuid"]] = item.text
end

# Regex to capture everything between double quotes
myreg = Regexp.new(/"([^"]+)"/)
# Store everything we parse
data = {}
curr_item = ""
# Read the files line by line, store everything in data as hashes
for file in [file1, file2] do
    IO.readlines(file).each do |line|
        if line[0..8] == "new entry"
            myreg.match(line)
            curr_item = $1
            data[curr_item] = {} # initialize an hash for the new item
        elsif line[0..3] == "type"
        elsif line[0..4] == "using"
            myreg.match(line)
            data[curr_item]["using"] = $1
        else
            scan = line.scan(myreg)
            if scan.size == 2
                data[curr_item][scan[0][0]] = scan[1][0]
            elsif scan.size == 1
                data[curr_item][scan[0][0]] = ""
            elsif scan.size > 2
                puts "Not handled scan size > 2"
            end
            
        end
    end
end


# Display the data
data.each do |id, param|
    puts loca[param["DisplayName"][0..-3]] if param["DisplayName"]
    puts id
    param.each do |key, val|
        case key
        when "RootTemplate"
            puts "    #{key}: #{val}"
        when "Description", "DisplayName", "ExtraDescription"
            puts "    #{key}: #{loca[val[0..-3]]}"
        else
            puts "    #{key}: #{val}"
        end
    end
    puts ""
end

puts "===== Parsing finished ====="