require 'spec_helper'

describe "StaticPages" do
	subject { page }

	describe "Home page" do
		before { visit root_path }

		it { should have_selector('title',     text: 'PammBook') }
	    it { should_not have_selector('title', text: '| Home') }
	end

	describe "About page" do
		before { visit about_path }

		it { should have_selector('title',      text: 'PammBook | About') }
		it { should have_content('About') }
	end

	it "should have the right links on the layout" do
	    visit root_path
		click_link "About"
		page.should have_selector 'title', text: 'About'
		click_link "Home"
		click_link "Sign up now!"
		page.should have_selector 'title', text: 'Sign up'
		click_link "pbook"
		page.should have_selector 'title', text: 'PammBook'
	end
end
