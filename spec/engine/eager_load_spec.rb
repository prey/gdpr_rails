require 'spec_helper'

describe 'PolicyManager eager loading' do
  it 'eager loads every engine file under Zeitwerk' do
    expect { Zeitwerk::Loader.eager_load_all }.not_to raise_error
    expect(PolicyManager::UserTermsController.ancestors).to include(PolicyManager::Concerns::UserTerms)
  end
end
