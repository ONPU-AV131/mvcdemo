
namespace :guestbook do
    desc "run guestbook"
    task "run" do
        require 'guestbook_fcgi'

        Rack::Handler::FastCGI.run GuestbookApp.new, :Port => 4000
    end
end
