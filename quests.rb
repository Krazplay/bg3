require 'nokogiri'
file = File.open('objective_prototypes.lsx', "r:UTF-8", &:read)
xml_objectives = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
file = File.open('quest_prototypes.lsx', "r:UTF-8", &:read)
xml_quests = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)
#file = File.open('questcategory_prototypes.lsx')
#xml_qcategories = Nokogiri::XML(file)
file = File.open('english.xml', "r:UTF-8", &:read)
localization = Nokogiri::XML(file, nil, Encoding::UTF_8.to_s)

# Redirect output to a file instead of the console
$stdout = File.new( './resultat.txt', 'w' )

# Parse the localization
text = {}
localization.xpath('/contentList/content').each do |item|
    text[item["contentuid"]] = item.text
end

# Parse the objectives
objectives = {}
xml_objectives.xpath('/save/region/node/children/node').each do |item|
    id = ""
    description = ""
    # Loop on the attribute nodes to find ID and description
    item.xpath('attribute').each do |attr|
        id = attr["value"] if attr["id"] == "ObjectiveID"
        description = attr["handle"] if attr["id"] == "Description"
    end
    objectives[id] = description
end

# Loop on nodes id="Quest"
xml_quests.xpath('/save/region/node/children/node').each do |item|
    # New quest
    quest = {};
    # Loop on all the quest 'attribute' nodes
    item.xpath('attribute').each do |attr|
        # QuestTitle doesn't have a 'value' param but 'handle'
        quest[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
    end
    puts "#{text[quest["QuestTitle"]]}"
    puts "    ID: #{quest["QuestID"]}"
    puts "    Parent Quest ID: " + quest["ParentQuestID"] if quest["ParentQuestID"] != ""
    puts "    Quest category: #{quest["CategoryID"]}"
    puts "    Quest visibility: " + quest["QuestVisiblity"] if quest["QuestVisiblity"] != "true"
    # Loop on QuestStep
    item.xpath('children/node').each do |stepNode|
        step = {}
        # Loop on QuestStep attributes
        stepNode.xpath('attribute').each do |attr|
            # If parameter doesn't have a 'value' param, use 'handle' instead
            step[attr["id"]] = attr["value"] != nil ? attr["value"] : attr["handle"]  
        end
        # When there's a children node, it's a kind of reward, for now store and display everything later
        # works for QuestRewardTables and QuestRewardOptionalTables but not RewardTemplateDescriptions!
        rewards = []
        stepNode.xpath('children/node').each do |childnode|
            next if childnode["id"] == "RewardTemplateDescriptions" # skip if reward template, I made another loop to manage them
            new_reward = {}
            new_reward["nodeid"] = childnode["id"]
            # Loop on attributes of current child
            childnode.xpath('attribute').each do |rew_attr|
                new_reward[rew_attr["id"]] = rew_attr["value"] != nil ? rew_attr["value"] : rew_attr["handle"]
            end
            rewards.push(new_reward)
        end
        # RewardTemplateDescriptions has its own children nodes... forced to loop again as it may contain multiple rewards in the future
        stepNode.xpath('children/node/children/node').each do |childnode|
            new_reward = {}
            new_reward["nodeid"] = childnode["id"]
            childnode.xpath('attribute').each do |rew_attr|
                new_reward[rew_attr["id"]] = rew_attr["value"] != nil ? rew_attr["value"] : rew_attr["handle"]
            end
            rewards.push(new_reward)
        end

        puts "   - " + text[step["Description"]].to_s  if (step["SubQuests"] == nil) # Normal quest step
        puts "   - Subquest: " + step["SubQuests"].to_s  if (step["SubQuests"] != nil) # Unlock new quest ?
        # No ID or dev comment for subquest, it's only for normal quest step
        if (step["SubQuests"] == nil)
            print "       " + step["ID"].to_s
            print " (dev comment: #{step["DevComment"].to_s})" if (step["DevComment"] != "" && step["DevComment"] != nil)
            puts ""
        end
        puts "       objective: " + text[objectives[step["Objective"]]].to_s if text[objectives[step["Objective"]]].to_s != ""
        puts "       Quest completed" if step["Objective"].to_s.include?("COMPLETION") # should be equivalent to description = ls::TranslatedStringRepository::s_HandleUnknown
        puts "       QuestRewardCount: " + step["QuestRewardCount"].to_s          if (step["QuestRewardCount"] != "0" && step["QuestRewardCount"] != nil)
        puts "       QuestRewardLevel: " + step["QuestRewardLevel"].to_s          if (step["QuestRewardLevel"] != "0" && step["QuestRewardLevel"] != nil)
        puts "       QuestTitleOverride: " + step["QuestTitleOverride"].to_s      if (step["QuestTitleOverride"] != "ls::TranslatedStringRepository::s_HandleUnknown" && step["QuestTitleOverride"] != nil)
        puts "       ReputationGain: " + step["ReputationGain"].to_s              if (step["ReputationGain"] != "0" && step["ReputationGain"] != nil)
                     # There is a SPACE after Gold in RewardAdditionalGold !
        puts "       RewardAdditionalGold: " + step["RewardAdditionalGold "].to_s                      if (step["RewardAdditionalGold "] != "00000000-0000-0000-0000-000000000000" && step["RewardAdditionalGold"] != nil)
        puts "       RewardAdditionalOwnerGUID: " + step["RewardAdditionalOwnerGUID"].to_s             if (step["RewardAdditionalOwnerGUID"] != "00000000-0000-0000-0000-000000000000" && step["RewardAdditionalOwnerGUID"] != nil)
        puts "       RewardAdditionalOwnerLevelName: " + step["RewardAdditionalOwnerLevelName"].to_s   if (step["RewardAdditionalOwnerLevelName"] != "" && step["RewardAdditionalOwnerLevelName"] != nil)
        puts "       RewardAdditionalOwnerName: " + step["RewardAdditionalOwnerName"].to_s             if (step["RewardAdditionalOwnerName"] != "" && step["RewardAdditionalOwnerName"] != nil)
        puts "       RewardAdditionalTreasureTable: " + step["RewardAdditionalTreasureTable"].to_s     if (step["RewardAdditionalTreasureTable"] != "" && step["RewardAdditionalTreasureTable"] != nil)

        # Show loot now
        rewards.each do |hash| 
            puts "       #{hash["nodeid"]}:"
            hash.each do |key, value|
                puts "            #{key}: #{value}" if (value != "" && value != nil && key != "nodeid")
            end
        end
    end
    # End of Quest
    puts ""
    puts ""
end
puts "===> Fin <==="