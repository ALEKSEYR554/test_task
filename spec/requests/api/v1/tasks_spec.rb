require 'swagger_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  path '/api/v1/tasks' do
    get 'List tasks' do
      tags 'Tasks'
      produces 'application/json'
      parameter name: :start_date, in: :query, type: :string, required: false
      parameter name: :end_date, in: :query, type: :string, required: false
      parameter name: :status, in: :query, type: :string, required: false

      response '200', 'tasks listed' do
        schema type: :array, items: { '$ref' => '#/components/schemas/Task' }
        run_test!
      end
    end

    post 'Create task' do
      tags 'Tasks'
      consumes 'application/json'
      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          due_date: { type: :string, format: 'date-time' },
          status: { type: :string },
          task_type: { type: :string },
          periodicity_type: { type: :string },
          periodicity_config: { type: :object },
          tag_ids: { type: :array, items: { type: :integer } }
        },
        required: ['title', 'due_date', 'status', 'task_type']
      }

      response '201', 'task created' do
        let(:task) { { title: 'Test', due_date: '2026-01-01T10:00:00Z', status: 'new', task_type: 'one_time' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:task) { { title: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/tasks/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Get task' do
      tags 'Tasks'
      produces 'application/json'

      response '200', 'task found' do
        schema '$ref' => '#/components/schemas/Task'
        let(:id) { Task.create(title: 'Test', due_date: '2026-01-01T10:00:00Z', status: 'new', task_type: 'one_time', user: User.first).id }
        run_test!
      end

      response '404', 'task not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    put 'Update task' do
      tags 'Tasks'
      consumes 'application/json'
      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          due_date: { type: :string, format: 'date-time' },
          status: { type: :string },
          task_type: { type: :string },
          periodicity_type: { type: :string },
          periodicity_config: { type: :object },
          tag_ids: { type: :array, items: { type: :integer } }
        }
      }

      response '200', 'task updated' do
        let(:id) { Task.create(title: 'Test', due_date: '2026-01-01T10:00:00Z', status: 'new', task_type: 'one_time', user: User.first).id }
        let(:task) { { title: 'Updated' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Task.create(title: 'Test', due_date: '2026-01-01T10:00:00Z', status: 'new', task_type: 'one_time', user: User.first).id }
        let(:task) { { title: '' } }
        run_test!
      end
    end

    delete 'Delete task' do
      tags 'Tasks'

      response '204', 'task deleted' do
        let(:id) { Task.create(title: 'Test', due_date: '2026-01-01T10:00:00Z', status: 'new', task_type: 'one_time', user: User.first).id }
        run_test!
      end

      response '404', 'task not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end