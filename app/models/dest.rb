class Dest < ActiveRecord::Base

  # Returns all dests which are created by user +user_id+
  def self.search_by_user_id(user_id, page)
    paginate_by_sql "" +
      "(SELECT \"debate\" AS type_id, id, NULL AS debate_id, NULL AS parent_id, title, body, fb_event_id, created_at " +
        "FROM debates " +
        "WHERE user_id = #{user_id}) " +
      "UNION " +
      "(SELECT \"argument\" AS type_id, id, debate_id, parent_id, title, body, null AS fb_event_id, created_at " +
        "FROM arguments " +
        "WHERE user_id = #{user_id}) " +
      "ORDER BY created_at DESC",
      :page => page, :per_page => 10
  end

  private
  # ...
  def self.instantiate(record)
    record['type_id'].classify.constantize.send(:instantiate, record) rescue super
  end
end
