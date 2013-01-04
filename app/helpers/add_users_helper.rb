module AddUsersHelper
  
  def primary_groups
    GoogleApps::ORG_UNIT_GROUPS.keys.map { |groupname| Directory::Group.find(groupname) }
  end
  
end
