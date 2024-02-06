class LeaveRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: String, default: 'pending'

  belongs_to :user, class_name: 'UserDetail', inverse_of: :leave_requests

  def approve!
    update(status: 'approved')
  end

  def reject!
    update(status: 'rejected')
  end

end
