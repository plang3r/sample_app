require 'spec_helper'

describe "UserPages" do
	
	subject { page }

	describe "index" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user
			visit users_path
		end

		it { should have_title('All users') }
		it { should have_content('All users') }
		it { should_not have_link('delete') }

		describe "pagination" do
			before(:all) { 30.times{ FactoryGirl.create(:user)  } }
			after(:all) { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					expect(page).to have_selector('li', text: user.name)
				end
			end
		end

		describe "as an admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			before do
				sign_in admin
				visit users_path
			end

			it { should have_link('delete', href: user_path(User.first)) }
			it "should be able to delete another user" do
				expect do
					click_link('delete', match: :first)
				end.to change(User, :count).by(-1)
			end
			it { should_not have_link('delete', href: user_path(admin)) }
		end
	end


	describe "profile page" do
		let(:user) { FactoryGirl.create(:user)  }
		let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "foo") }
		let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "bar") }

		before { visit user_path(user) }

		it { should have_content(user.name) }
	  it { should have_title(full_title(user.name)) }

		describe "microposts" do
			it { should have_content(m1.content) }
			it { should have_content(m2.content) }
			it { should have_content(user.microposts.count) }
		end
	end

	describe "signup page" do
		before { visit signup_path }

		it { should have_content('Sign up') }
	  it { should have_title(full_title('Sign up')) }
	end
	
	describe "signup" do
		before { visit signup_path }

		let(:submit) { "Create my account" }
		
		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			describe "after submission" do
				it "should show empty name error" do
						fill_in "Name", with: ""
						click_button submit
						expect { to have_selector("li", text: "Name can't be blank") }
				end
				it "should show empty email error" do
					fill_in "Email", with: ""
						click_button submit
						expect { to have_selector("li", text: "Email can't be blank") }
				end
				it "should show invalid email error" do
					fill_in "Email", with: "user@invalid"
						click_button submit
						expect { to have_selector("li", text: "Email is invalid") }
				end
				it "should show empty password error" do
					fill_in "Password", with: ""
						click_button submit
						expect { to have_selector("li", text: "Password can't be blank") }
				end
				it "should show empty confirmation error" do
					fill_in "Confirmation", with: ""
						click_button submit
						expect { to have_selector("li", text: "Password confirmation can't be blank") }
				end
				it "should show short password error" do
					fill_in "Password", with: "dude"
					fill_in "Confirmation", with: "dude"
						click_button submit
						expect { to have_selector("li", text: "Password is too short") }
				end
				it "should show non-matching password error" do
					fill_in "Password", with: "123456"
					fill_in "Confirmation", with: "654321"
						click_button submit
						expect { to have_selector("li", text: "Password confirmation doesn't match password") }
				end
			end		
		end

		describe "with valid information" do
			before do
				fill_in "Name",					with: "Example User"
				fill_in "Email", 				with: "user@example.com"
				fill_in "Password", 		with: "foobar"
				fill_in "Confirmation",	with: "foobar"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after submission" do
				before { click_button submit }
				let(:user) { User.find_by(email: "user@example.com") }

				it { should have_link("Sign out") }
				it { should have_title(user.name) }
				it { should have_selector('div.alert.alert-success', text: 'Welcome to the Sample App!') }
			end
		end
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			sign_in user
			visit edit_user_path(user)
		end
		
		describe "page" do
			it { should have_content("Update your profile") }
			it { should have_title("Edit user") }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		# describe "page for gravatar should appear in a new window" do
		# 	before { 
		# 		Capybara.current_driver = :selenium
		# 		click_link "change" 
		# 	}

		# 	it { should have_content("Update your profile") }
		# 	it { should have_title("Edit user") }
		# end

		describe "with invalid information" do
			before { click_button "Save changes" }

			it { should have_content('error') }
		end

		describe "with valid information" do
			let(:new_name) { "New Name" }
			let(:new_email) { "new_email@example.com" }
			before do 
				fill_in "Name",					with: new_name
				fill_in "Email",				with: new_email
				fill_in "Password", 		with: user.password
				fill_in "Confirmation", with: user.password_confirmation
				click_button "Save changes" 
			end

			it { should have_title(new_name) }
			it { should have_selector('div.alert.alert-success') }
			it { should have_link('Sign out', href: signout_path) }
			specify { expect(user.reload.name).to eq new_name }
			specify { expect(user.reload.email).to eq new_email }
		end

		describe "forbidden attributes" do
			let(:params) do
				{ user: { admin: true, password: user.password, 
									password_confirmation: user.password_confirmation } }
			end
			before { sign_in user, no_capybara: true }
			before { xhr :patch, user_path(user), params } 
			
			specify { expect(user.reload).not_to be_admin }
		end
	end

end			
