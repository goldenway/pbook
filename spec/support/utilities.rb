include ApplicationHelper

# methods for static pages spec

def should_have_correct_static_pages_links
    visit root_path
	click_link "About"
	page.should have_selector 'title', text: 'About'
	click_link "Home"
	click_link "Sign up now!"
	page.should have_selector 'title', text: 'Sign up'
	click_link "pbook"
	page.should have_selector 'title', text: 'PammBook'
end

# methods for authentication pages spec

def sign_in(user)
	visit signin_path
	fill_in "Name",     with: user.name
	fill_in "Password", with: user.password
	click_button "Sign in"

	# filling in the form doesn’t work when not using Capybara
	cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-error', text: message)
	end
end
