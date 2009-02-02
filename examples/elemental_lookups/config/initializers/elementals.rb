require 'elemental'

class PublicStatus
  extend Elemental

  member :unpublished,      :display => "Not Published", :default => true
  member :editor_approval,  :display => "Editorial Approval Needed"
  member :published,        :display => "Published"
  member :archived,         :display => "Archived"
end

class CommentType
  extend Elemental
  persist_ordinally

  member :all,        :display => "Anyone can post"
  member :moderated,  :display => "Moderated", :default => true
  member :closed,     :display => "Closed to new posts"
end
