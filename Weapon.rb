require 'nokogiri' # Require gem nokogiri to read XML files

# In game folder, Data/Localization/English.pak must be unpacked (LSLib Toolkit for example)
# Then convert Localization\English\english.loca to english.xml
file = File.open('english.xml', "r:UTF-8", &:read)
xml_localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# XXX_pak is the folder where I unpacked XXX.pak
file1 = 'E:\BG3_Unpack\Shared_pak\Public\Shared\Stats\Generated\Data\Weapon.txt'
file2 = 'E:\BG3_Unpack\Shared_pak\Public\SharedDev\Stats\Generated\Data\Weapon.txt'
file3 = 'E:\BG3_Unpack\Gustav_pak\Public\Gustav\Stats\Generated\Data\Weapon.txt'
file4 = 'E:\BG3_Unpack\Gustav_pak\Public\GustavDev\Stats\Generated\Data\Weapon.txt'

# Redirect output to a file instead of the console
$stdout = File.new( './Weapon.txt', 'w' )

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
for file in [file1, file2, file3, file4] do
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

# Loop for loading all the RootTemplates
template = {}
data.each do |id, param|
    filename = ""
    if not param["RootTemplate"].nil?
        # There are like 4 different places for game object templates ! Can't they sort their stuff ?!
        if File.exists?('E:\BG3_Unpack\Shared_pak\Public\Shared\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx')
            filename = 'E:\BG3_Unpack\Shared_pak\Public\Shared\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx'
        elsif File.exists?('E:\BG3_Unpack\Shared_pak\Public\SharedDev\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx')
            filename = 'E:\BG3_Unpack\Shared_pak\Public\SharedDev\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx'
        elsif File.exists?('E:\BG3_Unpack\Gustav_pak\Public\Gustav\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx')
            filename = 'E:\BG3_Unpack\Gustav_pak\Public\Gustav\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx'
        elsif File.exists?('E:\BG3_Unpack\Gustav_pak\Public\GustavDev\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx')
            filename = 'E:\BG3_Unpack\Gustav_pak\Public\GustavDev\RootTemplates_xml\\' + param["RootTemplate"] + '.lsx'
        else
            puts 'xxxxx KO xxxxxx   ' + param["RootTemplate"]
        end
        # Open the file, parse the file
        file = File.open(filename, "r:UTF-8", &:read)
        xml1 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
        # Create hash
        template[param["RootTemplate"]] = {}
        # Fill up hash
        pathx = '//node[@id="GameObjects"]'
        xml1.xpath(pathx).each do |item|
            # Store each attribute and its value
            storage = {}
            item.xpath('attribute').each do |attr|
                # If parameter doesn't have a 'value' param, use 'handle' instead
                storage[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
            end
            template[storage["MapKey"]] = storage;
        end
    end
end

# Display the data
data.each do |id, param|
    
    puts loca[template[param["RootTemplate"]]["DisplayName"]] if not param["RootTemplate"].nil?
    puts "id: #{id}"
    puts "    descr: " + loca[template[param["RootTemplate"]]["Description"]].to_s if not param["RootTemplate"].nil?
    param.each do |key, val|
        case key
        when "RootTemplate"
            puts "    #{key}: #{val}"
        else
            puts "    #{key}: #{val}"
        end
    end
    puts ""
end

puts "===== Parsing finished ====="