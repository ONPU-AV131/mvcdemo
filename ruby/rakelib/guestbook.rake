
namespace :guestbook do
    desc "run guestbook"
    task "run" do
        require 'guestbook_app'

        Rack::Handler::FastCGI.run GuestbookApp.new, :Port => 4000
    end
end
