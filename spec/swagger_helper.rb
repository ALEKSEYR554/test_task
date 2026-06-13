require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.to_s + '/swagger'

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Task Tracker API',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          Task: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              due_date: { type: :string, format: 'date-time' },
              status: { type: :string },
              task_type: { type: :string },
              periodicity_type: { type: :string },
              periodicity_config: { type: :object },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' },
              tags: { type: :array, items: { '$ref' => '#/components/schemas/Tag' } }
            }
          },
          Tag: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              color: { type: :string },
              is_required: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end