require "test_utils"

describe "arma2oaserver RPT log format" do
  extend LogStash::RSpec

  config <<-CONFIG
filter {
  grok {
    pattern => '%{TIME} "CRASHSPAWNER: %{NUMBER:spawn_chance}% chance to spawn %{QS:crash_type} with loot table %{QS:loot_table} at %{NUMBER:location}"'
    singles => true
  }
}
filter {
  grok{
    pattern => '%{TIME} "HIVE: WRITE: "CHILD:%{NUMBER:child_number}:"%{NUMBER}":%{LIST:loot}:%{NUMBER}"'
    patterns_dir => ['./patterns/arma-patterns']
    singles => true
    named_captures_only => true
  }
}
CONFIG

  sample "22:12:17 \"CRASHSPAWNER: 75% chance to spawn 'Crashed UH-1Y' with loot table 'Military' at 2135\"" do
    reject { subject["@tags"] }.include?("_grokparsefailure")

    insist { subject }.include?("crash_type")
    insist { subject }.include?("loot_table")
    insist { subject }.include?("spawn_chance")
    insist { subject }.include?("location")

    insist { subject["crash_type"] } == "'Crashed UH-1Y'"
    insist { subject["loot_table"] } == "'Military'"
    insist { subject["spawn_chance"] } == "75"
    insist { subject["location"] } == "2135"
  end
 
  sample '22:13:05 "HIVE: WRITE: "CHILD:303:"71":[[[],[]],[["30Rnd_556x45_StanagSD"],[5]],[[],[]]]:""' do
    reject { subject["@tags"] }.include?("_grokparsefailure")

    insist { subject }.include?("child_number")
    insist { subject }.include?("loot")

    insist { subject["child_number"] } == "303"
    insist { subject["loot"] } == '[[[],[]],[["30Rnd_556x45_StanagSD"],[5]],[[],[]]]'
  end

  sample '22:13:02 "HIVE: WRITE: "CHILD:303:"2":[[["Remington870_lamp","Makarov"],[1,1]],[["ItemJerrycan","30Rnd_556x45_Stanag","10x_303","15Rnd_9x19_M9","FoodCanBakedBeans","ItemSodaCoke","ItemPainkiller","ItemMorphine","FoodCanFrankBeans","ItemTankTrap","ItemSodaPepsi","ItemWaterbottleUnfilled"],[1,2,4,4,2,3,1,1,1,1,2,1]],[[],[]]]:""' do
    reject { subject["@tags"] }.include?("_grokparsefailure")

    insist { subject }.include?("child_number")
    insist { subject }.include?("loot")

    insist { subject["child_number"] } == "303"
    insist { subject["loot"] } == '[[["Remington870_lamp","Makarov"],[1,1]],[["ItemJerrycan","30Rnd_556x45_Stanag","10x_303","15Rnd_9x19_M9","FoodCanBakedBeans","ItemSodaCoke","ItemPainkiller","ItemMorphine","FoodCanFrankBeans","ItemTankTrap","ItemSodaPepsi","ItemWaterbottleUnfilled"],[1,2,4,4,2,3,1,1,1,1,2,1]],[[],[]]]'
  end

end

# Other samples to try later...

#22:13:05 "HIVE: WRITE: "CHILD:306:"71":[["glass1",1],["glass2",0.264],["glass3",0.353],["glass4",0.054],["wheel_1_1_steering",0.32],["wheel_1_2_steering",0.01],["wheel_2_1_steering",0.389],["wheel_2_2_steering",0.012],["motor",0.348],["karoserie",0.053],["palivo",0.154]]:0.012:""
