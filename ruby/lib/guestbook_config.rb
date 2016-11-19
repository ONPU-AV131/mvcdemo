
class GuestBookConfig
    include Singleton
    attr_reader :guest_records_path, :guest_records_mandatory_columns, :guest_records_optional_columns, :guest_records_columns,:template_dir
    def initialize
        @guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
        @guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
        @guest_records_optional_columns = [:state, :url]
        @guest_records_columns = @guest_records_mandatory_columns + @guest_records_optional_columns
        @template_dir = '/srv/www/mvcdemo.onpu/ruby/templates'
    end

end
