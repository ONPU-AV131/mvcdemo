class GuestbookController < ApplicationController
   def index
       @records = Record.all
   end
end
