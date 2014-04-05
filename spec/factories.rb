Factory.sequence :email do |e|
  "quentin_#{e}@example.com"
end
Factory.sequence :login do |l|
  "quentin_#{l}"
end
Factory.sequence :definition_name do |dn|
  "destination_name_#{dn}"
end
Factory.sequence :group_name do |gn|
  "group name #{gn}"
end
Factory.sequence :unique_hash do |h| 
  "unique-hash-#{h}"
end

Factory.define :category do |c|
  c.name         "History"
  c.description  "Some description goes here"
end

# Needed for generating activation emails (it has links pointing to 'em)
Factory.create(:category, :name => 'Support')          unless Category.support
Factory.create(:category, :name => 'Practice Debates') unless Category.practice_debate

Factory.define :definition do |d|
  d.name         { Factory.next(:definition_name) }
  d.description  "Definition Description"
end

Factory.define :user do |u|
  u.login                     { Factory.next(:login) }
  u.name                      "Quentin"
  u.email                     { Factory.next(:email) }
  u.password                  "quentin_password"
  u.password_confirmation     "quentin_password"
  u.state                     "pending"
  u.fb_user_id                nil
  u.fb_email_hash             nil
  u.identity_url              nil
 # u.is_admin                  false
end

Factory.define :admin_user, :parent => :user do |au|
  au.login                    'admin'
end

Factory.define :debate do |d|
  d.title            "Debate Title"
  d.category         { |c| c.association(:category) }
  d.user             { |c| c.association(:user) }
  d.link             "http://www.google.com/"
  d.body             "Debate Body"
  d.rating           2.30
  d.is_live          true
  d.priv             true
  d.is_debate_of_day false
  d.draft            false
  d.fb_event_id      nil
  d.fb_publish_stream_id nil
  d.is_freezed       false
end

Factory.define :public_debate, :parent => :debate do |d|
  d.is_live          true
  d.priv             false
  d.draft            0
  d.is_debate_of_day false
end

Factory.define :argument do |a|
  a.debate        { |c| c.association(:debate) }
  a.user          { |c| c.association(:user) }
  #a.parent        { |c| c.association(:argument) }
  a.definition    { |c| c.association(:definition) }
  a.argument_type 'pro'
  a.title         'Argument Title'
  a.body          'Argument Body'
  a.draft         0
  a.dest_id       nil
  a.relation_to_thumb 'pro'
end

Factory.define :message do |m|
  m.body         "Message body; message body; ..."
end

Factory.define :invitation do |i|
  i.resource      { |c| c.association(:debate) }
  i.resource_type "Debate"
  i.user          { |c| c.association(:user) }
  i.invitor       { |c| c.association(:user) }
  i.is_writable   true
  i.email         'someone@bestdebates.com'
  i.message       { |c| c.association(:message) }
  i.last_visited  Time.now
end

Factory.define :guest_invitation, :parent => :invitation do |gi|
  gi.user         nil
end

Factory.define :rating do |r|
  r.argument      { |c| c.association(:argument) }
  r.user          { |c| c.association(:user) }
  r.clarity       6
  r.relevance     1
  r.accuracy      4
end

Factory.define :argument_link do |a|
  a.url           "http://www.google.com"
  a.argument      { |c| c.association(:argument) }
  a.title         "Argument Link Title"
end

Factory.define :bookmark do |b|
  b.user          { |c| c.association(:user) }
  b.argument      { |c| c.association(:argument) }
  b.debate        { |c| c.association(:debate) }
end

Factory.define :code do |c|
  c.invitation    { |x| x.association(:invitation) }
  c.unique_hash   { Factory.next(:unique_hash) }
end

Factory.define :variable do |v|
  v.title         "Variable Title"
  #v.x             1.23
  v.q             1.23
  v.z             1.23
  v.r             1.23
 # v.y             1.23
  v.is_default    nil
  v.active        true
end
Factory.create(:variable) if Variable.count == 0   # needed for testing models rating, variable, etc.,

Factory.define :login do |l|
  l.name         "Login Name"
  l.user         { |x| x.association(:user) }
  l.loginid      Time.now.to_f
  l.duration     0
  l.visits       0
  l.sessid       "some sess id"
end

Factory.define :invite_link do |il|
  il.resource    { |x| x.association(:debate) }
  il.resource_type "Debate"
  il.user        { |x| x.association(:user) }
  il.unique_id   "823948293488923"
  il.title       "Invitation Title"
end

Factory.define :user_resource do |ud|
  ud.user        { |x| x.association(:user) }
  ud.resource    { |x| x.association(:debate) }
  ud.resource_type "Debate"
  ud.is_writable true
  ud.invite_link { |x| x.association(:invite_link) }
end

Factory.define :video do |v|
  v.argument     { |x| x.association(:argument) }
  v.code         "Video Code"
  v.played_times 20
end

Factory.define :group do |g|
  g.name         { Factory.next(:group_name) }
  g.unique_hash  { Factory.next(:unique_hash) }
  g.creator      { |x| x.association(:user) }
end

Factory.define :sponsor_user do |su|
  su.sponsor     { |x| x.association(:user) }
  su.user        { |x| x.association(:user) }
  su.email_sent  true
end

Factory.define :similar_argument do |sa|
  sa.argument            { |x| x.association(:argument) }
  sa.identification_hash 'aksldjflkasjdflkjasdflkjaskldjflaksjdf'
end


