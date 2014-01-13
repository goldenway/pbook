require 'spec_helper'

describe "StaticPages" do
	subject { page }

	describe "Home page" do
		before { visit root_path }

		it { should have_selector('title',     text: 'PammBook') }
	    it { should_not have_selector('title', text: full_title('Home')) }
	end

	describe "About page" do
		before { visit about_path }

		it { should have_selector('title',      text: full_title('About')) }
		it { should have_content('About') }
	end

	describe "should have the right links on the layout" do
		it { should_have_correct_static_pages_links } # defined in spec/support/utilities.rb
	end
end
