require 'swagger_helper'

RSpec.describe 'Api::V1::Tags', type: :request do
  path '/api/v1/tags' do
    get 'List tags' do
      tags 'Tags'
      produces 'application/json'

      response '200', 'tags listed' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Tag' }
        run_test!
      end
    end

    post 'Create tag' do
      tags 'Tags'
      consumes 'application/json'
      parameter name: :tag, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          color: { type: :string }
        },
        required: ['name', 'color']
      }

      response '201', 'tag created' do
        let(:tag) { { name: 'Test Tag', color: '#FF0000' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:tag) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/tags/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Get tag' do
      tags 'Tags'
      produces 'application/json'

      response '200', 'tag found' do
        schema '$ref' => '#/components/schemas/Tag'
        let(:id) { Tag.create(name: 'Test', color: '#FF0000', user: User.first).id }
        run_test!
      end

      response '404', 'tag not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    put 'Update tag' do
      tags 'Tags'
      consumes 'application/json'
      parameter name: :tag, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          color: { type: :string }
        }
      }

      response '200', 'tag updated' do
        let(:id) { Tag.create(name: 'Test', color: '#FF0000', user: User.first).id }
        let(:tag) { { name: 'Updated' } }
        run_test!
      end

      response '403', 'forbidden - required tag' do
        let(:id) { Tag.create(name: 'Required', color: '#FF0000', is_required: true).id }
        let(:tag) { { name: 'Updated' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Tag.create(name: 'Test', color: '#FF0000', user: User.first).id }
        let(:tag) { { name: '' } }
        run_test!
      end
    end

    delete 'Delete tag' do
      tags 'Tags'

      response '204', 'tag deleted' do
        let(:id) { Tag.create(name: 'Test', color: '#FF0000', user: User.first).id }
        run_test!
      end

      response '403', 'forbidden - required tag' do
        let(:id) { Tag.create(name: 'Required', color: '#FF0000', is_required: true).id }
        run_test!
      end

      response '404', 'tag not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end