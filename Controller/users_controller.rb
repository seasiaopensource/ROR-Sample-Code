=begin
  User controller For User operations
  @author Seasia Team <singhharpreet2@seasiainfotech.com>
=end

class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:new]
    before_action :set_user, only: [:index, :show, :edit, :update, :destroy]
    before_action :set_current_user
  
    #Index function for rendering all users
    def index
      @users = User.all
      add_breadcrumb 'All Users'
       respond_to  do |format|
         format.html
         format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
       end
    end
    #Default Show function in ror
    def show
    end
    #New function for creating new user object
    def new
      @user = User.new
    end 
    #Create function for saving the User in the database
    def create
      @user = User.new(user_params)
      if @user.save
        flash[:success] = "User created successfully."
      else
        render 'new'
      end
    end
    #Update function for updating USer Info
    def update
      @user = User.find_by(id: params[:user_id])
      if @user.update_attributes(user_params)
        sign_in(current_user, :bypass => true)
        respond_to do |format|
          format.js
        end
      else
        flash.now["error"] = "Failed to update user"
        render('edit')
      end
    end

    #Edit function for Editing the USer  
    def edit
      add_breadcrumb 'Edit Profile'
    end
    #Destroy function for deleting the USer
    def destroy
      @user.destroy
      flash[:success] = "User has been deleted."
      redirect_to(controller: 'dashboard', action: 'vendors')
    end
    #Register function for displaying the User Details on frontend
    def register
      @company = CompanyDetail.find_by(:user_id => current_user.id)
      if !@company
        @company = CompanyDetail.new
      end
      @bank = BankDetail.find_by(:user_id => current_user.id)
      if !@bank
        @bank = BankDetail.new
      end
      session[:action_type] = "sales_agreements"
      
    end
    #Function for loading the USer by id and editing the User info in popup
    def open_edit_modal
      @user = User.find_by(id: params[:user_id])
      respond_to do |format|
        format.js
      end
    end
    #Function for setting Current User object
    def set_current_user
      User.current(current_user)
       
    end
    #Function for loading the USer by id and displaying the User info in popup
    def open_info_modal

      @user = User.find_by_id(params[:user_id])
      respond_to do |format|
        format.js
      end 
    end

    #Class Private Functions
    private
    #Set User by Id
    def set_user
      @user = User.find_by(id: params[:id])
    end
    #Set user params for saving the fields in the database
    def user_params
      params.require(:user).permit(
        :user_id,
        :first_name,
        :last_name,
        :email,
        :phone,
        :sign_up_code,
        :password,
        :password_confirmation,
        :remember_me,
        :roles_mask,
        :parent_id,
        roles: [:admin, :buyer, :supplier],
        )
    end
end

