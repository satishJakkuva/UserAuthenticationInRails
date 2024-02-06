class LeaveRequestsController < ApplicationController
    before_action :authenticate_user 
    before_action :load_leave_request, only: %i[ update destroy approve reject  calculate_leave_duration]
   
    # api to list out all the leave requests based on user and as well all users
    def index
        if params[:user_id].present?
            @user_details = UserDetail.find(params[:user_id])   
            @leave_requests = @user_details.leave_requests
        else
            @leave_requests = LeaveRequest.all
        end
         render json: @leave_requests
    end
    # api to create a leave request
    def create
        @leave_request = @user_details.leave_requests.new(leave_request_params)
        if @leave_request.save
          render json: { message: 'Leave request created successfully', status: 200 }
        else
          render json: { message: 'Failed to create leave request', status: 500 }
        end
    end
   #api to update a leave request   
    def update
        if @leave_request.update(leave_request_params)
          render json: { message: 'Leave request updated successfully', status: 200 }
        else
          render json: { message: 'Failed to update leave request', status: 500 }
        end
    end
   #api to delete a leave request
    def destroy
        @leave_request.destroy
        render json: { message: 'Leave request deleted successfully', status: 200 }
    end
   #api to approve a leave request
    def approve
        @leave_request.approve!
        render json: { message: 'Leave request approved ', status: 200 }
    end
  #api to reject a leave request
    def reject
        @leave_request.reject!
        render json: { message: 'Leave request rejected ', status: 200 }
    end

    def calculate_leave_duration
       if @leave_request.present? && @leave_request.start_date.present? && @leave_request.end_date.present?
        leave_days = business_days_between(@leave_request.start_date,@leave_request.end_date)
        render json: { leave_duration: leave_days, status: 200 }
       else
        render json: { message: 'leave request days are not valid'}
       end
    end

    private
    def leave_request_params
        params.require(:leave_request).permit(:start_date, :end_date)
    end
    def load_leave_request
        begin
          @leave_request = @user_details.leave_requests.find(params[:id])
        rescue Mongoid::Errors::DocumentNotFound
          render json: { error: 'Leave request not found' }, status: :not_found
        end
    end 
    def authenticate_user
        token = request.headers['Authorization']
        if token.blank?
            render json: { message: "authentication token cannot be blank"}
        else
            begin
                 @user_details = UserDetail.find_by(authentication_token: token)
                 unless @user_details && @user_details.status == 'active'
                    render json: { message: 'Unauthorized', status: 401 }
                end
            rescue Mongoid::Errors::DocumentNotFound
                render json: {  message: 'Unauthorized user', status: 401}
            end
        end   
    end
    def business_days_between(start_date,end_date)
        (start_date..end_date).count{ |date| (1..5).include?(date.wday) }
    end
end
