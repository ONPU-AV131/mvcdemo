require 'csv'

require 'guestbook_config'
class Record
    attr_reader :missing_fields

    @@config = GuestBookConfig.instance

    def initialize(params)
        check_missing_fields params

        unless have_missing_fields?
            set_fields params
        end
    end

    def [](key)
        self.instance_variable_get("@#{key}")
    end

    def save
        unless have_missing_fields?
            CSV.open(@@config.guest_records_path, "ab") do |csv|
                csv << to_a
            end
        end
    end

    def have_missing_fields?
        !@missing_fields.empty?
    end

    def self.all
        records = []
        if File.exists? @@config.guest_records_path
            CSV.foreach @@config.guest_records_path do |row|
                params =  Hash[ @@config.guest_records_columns.each_index.map {|i| [@@config.guest_records_columns[i], row[i]]} ]
                record = Record.new(params)
                records.push record unless record.have_missing_fields?
            end
        end
        records
    end

    private
    def check_missing_fields(params)
        @missing_fields = []
        @@config.guest_records_mandatory_columns.each do |column|
            if !params[column] || params[column].empty?
                @missing_fields.push column
            end
        end
    end

    def set_fields(params)
        @@config.guest_records_columns.each do |column|
            self.instance_variable_set("@#{column}", params[column])
        end
    end

    def to_a
        @@config.guest_records_columns.map {|column| self[column]}
    end
end
