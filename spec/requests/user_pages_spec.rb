require 'spec_helper'

describe "UserPages" do
	
	subject { page }

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user)  }
		before { visit user_path(user) }

		it { should have_content(user.name) }
	  it { should have_title(full_title(user.name)) }
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
end			
