#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Components
  module Timelines
    class TimelineRow
      include Capybara::DSL
      include Capybara::RSpecMatchers
      include RSpec::Matchers

      attr_reader :container

      def initialize(container)
        @container = container
      end

      def hover!
        @container.find('.timeline-element').hover
      end

      def expect_hovered_labels(left:, right:)
        hover!

        unless left.nil?
          expect(container).to have_selector(".labelHoverLeft.not-empty", text: left)
        end
        unless right.nil?
          expect(container).to have_selector(".labelHoverRight.not-empty", text: right)
        end

        expect(container).to have_selector(".labelLeft", visible: false)
        expect(container).to have_selector(".labelRight", visible: false)
        expect(container).to have_selector(".labelFarRight", visible: false)
      end

      def expect_labels(left:, right:, farRight:)
        {
          labelLeft: left,
          labelRight: right,
          labelFarRight: farRight
        }.each do |className, text|
          if text.nil?
            expect(container).to have_selector(".#{className}", visible: :all)
            expect(container).to have_no_selector(".#{className}.not-empty", wait: 0)
          else
            expect(container).to have_selector(".#{className}.not-empty", text:)
          end
        end
      end

      def hover_bar(offset_days: 0)
        container.hover
        offset_x = offset_days * 30
        page.driver.browser.action.move_to(@container.native, offset_x).perform
      end

      def click_bar(offset_days: 0)
        hover_bar(offset_days:)
        page.driver.browser.action.click.perform
      end

      def expect_hovered_bar(duration: 1)
        expected_length = duration * 30
        expect(container).to have_selector('div[class^="__hl_background_"', style: { width: "#{expected_length}px" })
      end

      def expect_bar(duration: 1)
        loading_indicator_saveguard
        expected_length = duration * 30
        expect(container).to have_selector('.timeline-element', style: { width: "#{expected_length}px" })
      end

      def expect_no_hovered_bar
        expect(container).not_to have_selector('div[class^="__hl_background_"')
      end

      def expect_no_bar
        loading_indicator_saveguard
        expect(container).not_to have_selector('.timeline-element')
      end

      def drag_and_drop(offset_days: 0, days: 1)
        container.hover
        offset_x_start = offset_days * 30
        start_dragging(container, offset_x: offset_x_start)
        offset_x = ((days - 1) * 30) + offset_x_start
        drag_element_to(container, offset_x:)
        drag_release
      end
    end
  end
end
