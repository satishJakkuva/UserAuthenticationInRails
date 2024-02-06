class UserDetailsController < ApplicationController
    before_action :load_user_by_user_id, only: %i[show ]
    def index 
        @users=UserDetail.all
        render json: @users
    end
    def create
        @user_details=UserDetail.new(request_user_params)
        if @user_details.save
            render json: {message: "user details saved successfully ",status: 200}
        else
            render json: {message: "failed to register an user "}
        end
    end
    
    def show
        render json:@user
    end

    def login
        @user_details = UserDetail.find_by(email:params[:email])
        puts "#{@user_details.email}"
        puts "#{@user_details.authenticate(params[:password])}"
        if @user_details && @user_details.authenticate(params[:password])   
           @user_details.authentication_token=@user_details.generate_authentication_token  
          if @user_details.save
            render json: { authentication_token: @user_details.authentication_token, status: 200 }
          end
        else
          render json: { message: "Invalid email or password", status: 401 }
        end  
    end

    def update_status
      begin
        @user_details = UserDetail.find(params[:id])
        if @user_details.update(status: params[:status])
          render json: { message: "User status updated to #{params[:status]}", status: 200 }
        else
          render json: { message: "Failed to update user status to #{params[:status]}", status: 500 }
        end
      rescue Mongoid::Errors::DocumentNotFound => e
        render json: { message: "User with ID #{params[:id]} not found", status: 404 }
      end
    end
    
      
    private 
    def request_user_params
        params.require(:user_details).permit(:first_name,:last_name,:email,:password,:primary_phone_number,:authentication_token,:dob,:status)
    end
    # def user_login_params
    #     params.permit(:email,:password)
    # end
    def load_user_by_user_id
        begin
            @user_details = UserDetail.find(params[:id])
            render json: @user_details
          rescue Mongoid::Errors::DocumentNotFound
            render json: { error: 'User not found' }, status: :not_found
        end
    end
    

end
