module AfterCommit
  def self.record(connection, record)
    add_to_collection  :committed_records, connection, record
  end

  def self.record_created(connection, record)
    add_to_collection  :committed_records_on_create, connection, record
  end

  def self.record_updated(connection, record)
    add_to_collection  :committed_records_on_update, connection, record
  end

  def self.record_saved(connection, record)
    add_to_collection  :committed_records_on_save, connection, record
  end

  def self.record_destroyed(connection, record)
    add_to_collection  :committed_records_on_destroy, connection, record
  end
  
  def self.records(connection)
    collection :committed_records, connection
  end

  def self.created_records(connection)
    collection :committed_records_on_create, connection
  end

  def self.updated_records(connection)
    collection :committed_records_on_update, connection
  end

  def self.saved_records(connection)
    collection :committed_records_on_save, connection
  end

  def self.destroyed_records(connection)
    collection :committed_records_on_destroy, connection
  end

  def self.cleanup(connection)
    [
      :committed_records,
      :committed_records_on_create,
      :committed_records_on_update,
      :committed_records_on_save,
      :committed_records_on_destroy
    ].each do |collection|
      Thread.current[collection]                        ||= {}
      Thread.current[collection][connection.old_transaction_key] = []
    end
  end
  
  def self.add_to_collection(collection, connection, record)
    collection_map = collection_map(collection)
    transaction_key = connection.unique_transaction_key

    records = collection_map[transaction_key]
    if (records)
      records << record
    else
      collection_map[transaction_key] = [record]
    end
  end
  
  def self.collection(collection, connection)
    collection_map(collection)[connection.old_transaction_key] ||= []
  end

  def self.collection_map(collection)
    Thread.current[collection] ||= {}
  end
end

require 'after_commit/active_support_callbacks'
require 'after_commit/active_record'
require 'after_commit/connection_adapters'
require 'after_commit/after_savepoint'

ActiveRecord::Base.send(:include, AfterCommit::ActiveRecord)
ActiveRecord::Base.include_after_commit_extensions
