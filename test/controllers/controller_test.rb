class SessionsController < ApplicationController

	#post session
	def create
		@session = Session.new(session_params)

		if @session.save

			turn_plug_on

			render json: { id: @session.id, time_in: @session.time_in},status: :created
		else
      		render json: { errors: @session.errors.full_messages }, status: :unprocessable_entity
    	end
    end

  	def update

  		@session = Session.find(params[:id])

  		if @session.update(session_params)

  			turn_plug_off

  			render json: {
  				duration: @session.duration_mins,
  				membership_id: @session.membership_id,
				total_cost: @session.total_cost,
  				receipt: "#{@session.duration_mins} mins, Member ##{@session.membership_id}, AED #{@session.total_cost}"
						}, status: :ok
		else
      		render json: { errors: @session.errors.full_messages }, status: :unprocessable_entity
      	end
  	end



 private

		def session_params
    	params.require(:session)
          .permit(:time_in, :time_out, :price_per_minute, :membership_id)
  	end


  		def render_session_invoice(session, status: ok)

  			render json: {
  				duration: @session.duration_mins,
  				membership_id: @session.membership_id,
				total_cost: @session.total_cost,
  				receipt: "#{@session.duration_mins} mins, Member ##{@session.membership_id}, AED #{@session.total_cost}"
						}, status: :ok
		end

		


  		def turn_plug_on
    # …
  	end

  		def turn_plug_off
    # …
  	end
end

