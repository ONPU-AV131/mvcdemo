class GuestbookController < ApplicationController
   def index
       @records = Record.all
   end

   def create
       record = Record.create(record_params)
       redirect_to action: 'index'
   end

   private
   def record_params
       params.require(:record).permit(:name, :email, :city, :country, :comments, :state, :url)
   end
end
