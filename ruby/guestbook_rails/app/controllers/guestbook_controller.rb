class GuestbookController < ApplicationController
   def index
       @records = Record.all
       @record = Record.new
   end

   def create
       @record = Record.new(record_params)
       if @record.save
           redirect_to action: 'index'
       else
           @records = Record.all
           render :index
       end

   end

   private
   def record_params
       params.require(:record).permit(:name, :email, :city, :country, :comments, :state, :url)
   end
end
