require 'nokogiri' # Require gem nokogiri to read XML files

# In game folder, Data/Localization/English.pak must be unpacked (LSLib Toolkit for example)
# Then convert Localization\English\english.loca to english.xml
file = File.open('english.xml', "r:UTF-8", &:read)
xml_localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# XXX_pak is the folder where I unpacked XXX.pak
file = File.open('E:\BG3_Unpack\Shared_pak\Public\Shared\Gods\Gods.lsx', "r:UTF-8", &:read)
xml1 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
file = File.open('E:\BG3_Unpack\Shared_pak\Public\SharedDev\Gods\Gods.lsx', "r:UTF-8", &:read)
xml2 = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# Redirect output to a file instead of the console
$stdout = File.new( './Gods.txt', 'w' )

puts "=====  Parsing start   ====="
puts ""
puts "TODO: Tags"
puts ""

# Parse the localization, create an hash: loca[UID] = human readable text
loca = {}
xml_localization.xpath('/contentList/content').each do |item|
    loca[item["contentuid"]] = item.text
end

# Loop on the interesting nodes of both file
pathx = '//node[@id="God"]'
(xml1.xpath(pathx)+xml2.xpath(pathx)).each do |item|
    # Store each attribute and its value
    storage = {}
    item.xpath('attribute').each do |attr|
        # If parameter doesn't have a 'value' param, use 'handle' instead
        storage[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
    end

    # Display the data
    puts "God " + loca[storage["DisplayName"]]
    storage.each do |key, val|
        case key
        when "Description", "DisplayName"
            puts "    #{key}: #{loca[val]}"
        else
            puts "    #{key}: #{val}"
        end
    end
    puts ""
end

puts "===== Parsing finished ====="