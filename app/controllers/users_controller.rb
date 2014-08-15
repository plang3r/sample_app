class UsersController < ApplicationController
	before_action :signed_in_user, 	only: [:index, :edit, :update, :user_page]
	before_action :signed_out_user, only: [:new, :create]
	before_action :correct_user, 		only: [:edit, :update]
	before_action :admin_user, 			only: [:destroy]

	def index
		@users = User.paginate(page: params[:page])
	end

  def show
		@user = User.find(params[:id])
	end

	def new
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	def destroy
		@user = User.find(params[:id])
		if !current_user?(@user)
			@user.destroy
			flash[:success] = "User deleted."
			redirect_to users_url
		else
			redirect_to root_url
		end
	end

#	def user_page
#		render :json => get_user_page(params[:page]).to_json
#	end


	private
		def user_params
			params.require(:user).permit(:name, :email, :password,
																	 :password_confirmation)
		end

		def signed_in_user
			unless signed_in?
				store_location
				redirect_to signin_path, notice: "Please sign in."
			end
		end

		def signed_out_user
			redirect_to root_url unless !signed_in?
		end

		def correct_user
			@user = User.find_by(id: params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end

		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

#		def gravatar_for(user, options = { size: 50 })
#			gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
#			size = options[:size]
#			gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
#			view_context.image_tag(gravatar_url, alt: user.name, class: "gravatar")
#		end
#
#		def get_user_page(page_num)
#			user_entries = "" 
#			User.paginate(page: page_num).each do |user|
#				user_entries += view_context.content_tag(:li, gravatar_for(user) + view_context.link_to(user.name, user))
#			end
#			user_entries	
#		end

	end
