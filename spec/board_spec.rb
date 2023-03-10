require 'spec_helper'

RSpec.describe Board do
  let(:board) {board = Board.new}
  let(:cruiser) {cruiser = Ship.new("Cruiser", 3)}
  let(:submarine) {submarine = Ship.new("Submarine", 2)}

  describe '#the board' do
    it 'the board exists' do
      expect(board).to be_a Board
    end

    it 'the board has a hash of cell objects' do
      expect(board.cells).is_a?(Hash)
    end
  end

  describe '#valid cooridnates' do
    it 'the board can identify and validate a cooordinate' do
      expect(board.valid_coordinate?("A1")).to be true
      expect(board.valid_coordinate?("E1")).to be false
    end
  end

  describe '#valid placements' do
    it 'it can check if the ships placement is valid' do
      expect(board.valid_placement?(cruiser, ["A1", "A2"])).to be false
      expect(board.valid_placement?(submarine, ["A2", "A3", "A4"])).to be false
    end

    it 'it can check if the coordiante are consecutive in the correct direction' do
      expect(board.valid_placement?(cruiser, ["A1", "A2", "A4"])).to be false
      expect(board.valid_placement?(submarine, ["A1", "C1"])).to be false
      expect(board.valid_placement?(cruiser, ["A3", "A2", "A1"])).to be false
      expect(board.valid_placement?(submarine, ["C1", "B1"])).to be false
    end

    it 'it can check for and reject diagonal coordiates' do
      expect(board.valid_placement?(cruiser, ["A1", "B2", "C3"])).to be false
      expect(board.valid_placement?(submarine, ["C2", "D3"])).to be false
    end

    it 'can confirm placement is correct after passing previous checks' do
      expect(board.valid_placement?(cruiser, ["B1", "C1", "D1"])).to be true
      expect(board.valid_placement?(submarine, ["A1", "A2"])).to be true 
    end
  end

  describe '#placing ships' do
    it 'can place ships in multiple consecutive cells' do
      cell_1 = board.cells["A1"]
      cell_2 = board.cells["A2"]
      cell_3 = board.cells["A3"]
      board.place(cruiser, ["A1", "A2", "A3"])
      
      expect(cell_1.ship).to eq(cruiser)
      expect(cell_2.ship).to eq(cruiser)
      expect(cell_3.ship).to eq(cruiser)
      expect(cell_1.ship == cell_2.ship).to be true
      expect(cell_2.ship == cell_3.ship).to be true
      expect(cell_3.ship == cell_2.ship).to be true
    end

    it 'makes sure that ships cant overlap' do
      board.place(cruiser, ["A1", "A2", "A3"])
      board.place(submarine, ["A1", "B1"])

      expect(board.place(cruiser, ["A1", "A2", "A3"])).to eq(["A1", "A2", "A3"])
      expect(board.valid_placement?(submarine, ["A1", "B1"])).to be false
    end
  end
  
  describe '#rendering the board' do
    it 'can render a 4X4 board' do
      expect(board.render).to eq("  1 2 3 4 \nA . . . . \nB . . . . \nC . . . . \nD . . . .")
    end

    it 'can render 4X4 board with ship' do
      board.place(cruiser, ["A1", "A2", "A3"])

      expect(board.render).to eq("  1 2 3 4 \nA . . . . \nB . . . . \nC . . . . \nD . . . .")
      expect(board.render(true)).to eq("  1 2 3 4 \nA S S S . \nB . . . . \nC . . . . \nD . . . .")
    end

    it 'can render board with misses, hits, and sinks' do
      cell_1 = board.cells["A1"]
      cell_2 = board.cells["A2"]
      cell_3 = board.cells["A3"]
      cell_4 = board.cells["A4"]

      board.place(cruiser, ["A1", "A2", "A3"])
      cell_1.fire_upon

      expect(board.render).to eq("  1 2 3 4 \nA H . . . \nB . . . . \nC . . . . \nD . . . .")

      cell_4.fire_upon
      cell_3.fire_upon
      cell_2.fire_upon

      expect(board.render).to eq("  1 2 3 4 \nA X X X M \nB . . . . \nC . . . . \nD . . . .")
    end
  end
end