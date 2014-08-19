require 'spec_helper'

describe "Authentication" do

	subject { page }
	let(:user) { FactoryGirl.create(:user) }

	describe "signin page" do
		before { visit signin_path }

		it { should have_content('Sign in') }
		it { should have_title('Sign in') }

		describe "with invalid information" do
			before { click_button "Sign in" }

			it { should have_title('Sign in') }
			it { should have_selector('div.alert.alert-error') }

			it { should_not have_title(user.name) }
			it { should_not have_link('Users',		href: users_path) }
			it { should_not have_link('Profile',	href: user_path(user)) }
			it { should_not have_link('Settings',	href: edit_user_path(user)) }
			it { should_not have_link('Sign out', href: signout_path) }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			before { sign_in user }

			it { should have_title(user.name) }
			it { should have_link('Users',		href: users_path) }
			it { should have_link('Profile',	href: user_path(user)) }
			it { should have_link('Settings',	href: edit_user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }
			it { should_not have_link('Sign in', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in') }
			end
		end

	end

	describe "authorization" do
		describe "for signed-in users" do
			before { sign_in user }

			describe "accessing signup page" do
				before { visit signup_path }

				it { should_not have_title(full_title('Sign up')) }
				it { should have_title(full_title('')) }
			end

			describe "submitting a POST request to the Users#create action" do
				let(:params) do
					{ user: { name: "Pablo Herman", 
										email: "pabloh@are.net",
										password: user.password, 
										password_confirmation: user.password_confirmation } }
				end
				before { sign_in user, no_capybara: true }
				before { post users_path, params }

				specify { expect(response).to redirect_to(root_url) }
				end
			end

			describe "for non-signed-in users" do
				describe "when attempting to visit a protected page" do
					before do
						visit edit_user_path(user)
						# visit should redirect to sign_in page
						fill_in "Email",		with: user.email
						fill_in "Password", with: user.password
						click_button "Sign in"
					end

					describe "after signing in" do
						it { should have_title('Edit user') }
					end

					describe "forwarding link should only be valid after 1st signin" do
						before do 
							sign_out user
							sign_in user
						end

						it { should_not have_title('Edit user') }
					end

					describe "in the Microposts controller" do
						describe "submitting to the create action" do
							before { post microposts_path }
							specify { expect(response).to redirect_to(signin_path) }
						end

						describe "submitting to the destroy action" do
							before { delete micropost_path(FactoryGirl.create(:micropost)) }
							specify { expect(response).to redirect_to(signin_path) }
						end
					end
				end

				describe "in the Users controller" do
					describe "visiting the edit page" do
						before { visit edit_user_path(user) }

						it { should have_title('Sign in') }
					end

					describe "submitting to the update action" do
						before { patch user_path(user) }
						specify { expect(response).to redirect_to(signin_path) }
					end

					describe "visiting the user index" do
						before { visit users_path }
						it { should have_title('Sign in') }	
					end
				end

				describe "as non-admin user" do
					let(:user) { FactoryGirl.create(:user) }
					let(:non_admin) { FactoryGirl.create(:user) }

					before { sign_in non_admin, no_capybara: true }

					describe "submitting a DELETE request to the Users#destroy action" do
						before { delete user_path(user) }
						specify { expect(response).to redirect_to(root_url) }

					end
				end
			end

			describe "as wrong user" do
				let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
				before { sign_in user, no_capybara: true }

				describe "submitting a GET request to the Users#edit action" do
					before { get edit_user_path(wrong_user) }
					specify { expect(response.body).not_to match(full_title('Edit user')) }
					specify { expect(response).to redirect_to(root_url) }
				end	

				describe "submitting a PATCH request to the Users#update action" do
					before { patch user_path(wrong_user) }
					specify { expect(response).to redirect_to(root_url) }
				end

				describe "submitting a DELETE request to the Microposts#destroy action for another user" do
					let!(:other_user) { FactoryGirl.create(:user) }
					let!(:other_micropost) { FactoryGirl.create(:micropost, user: other_user) }

					before { delete micropost_path(other_micropost)	}
					
					specify { expect(response).to redirect_to(root_url) }
				end
			end

			describe "as admin user" do
				describe "submitting a DELETE request for himself to the Users#destroy action" do
					let(:admin) { FactoryGirl.create(:admin) }
					before do
						sign_in admin, no_capybara: true
						delete user_path(admin)
					end	

					specify { expect(response).to redirect_to(root_url) }
				end
			end

		end
	end
