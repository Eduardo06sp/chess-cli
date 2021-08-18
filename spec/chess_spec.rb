# frozen_string_literal: true

require_relative '../lib/chess'

describe Chess do
  let(:player_one) { instance_double(Player) }
  let(:player_two) { instance_double(Player) }
  subject(:new_game) { Chess.new(player_one, player_two) }

  describe '#fill_king_rank' do
  end
end
