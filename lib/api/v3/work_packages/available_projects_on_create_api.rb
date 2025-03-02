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

module API
  module V3
    module WorkPackages
      class AvailableProjectsOnCreateAPI < ::API::OpenProjectAPI
        resource :available_projects do
          after_validation do
            authorize(:add_work_packages, global: true)

            checked_permissions = Projects::ProjectCollectionRepresenter.checked_permissions
            current_user.preload_projects_allowed_to(checked_permissions)
          end

          get &::API::V3::Utilities::Endpoints::SqlFallbackedIndex
            .new(model: Project,
                 self_path: -> { api_v3_paths.available_projects_on_create },
                 scope: -> {
                   WorkPackage
                     .allowed_target_projects_on_create(current_user)
                     .includes(Projects::ProjectCollectionRepresenter.to_eager_load)
                 })
            .mount
        end
      end
    end
  end
end
