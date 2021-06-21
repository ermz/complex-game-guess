# @version ^0.2.0



#Contract guess number
# contract should support multiple guess the number games
# creator of games should risk 10 eth to start a new game
# a secret number is established during game creation
# the secret number should be between 0-100
#the game creator cannot play in the games he created
# each guess of the number in a game will cost 1 eth
#each game should allow only 10 guesses, once the tenth guess is made
#the contract will expire and the funds will got ot hte game creator
#whoever makes the right guess will win the balance of the game
#once the right guess is made a gmae should not allow people to play
#Once a game make a payment 1% of the amount will go to the contract as a fee

struct game:
    game_owner: address
    secret_number: uint256
    game_balance: uint256
    guess_count: uint256
    is_active: bool

curr_id: uint256

game_index: HashMap[uint256, game]

contract_owner: address

@external
def __init__():
    self.contract_owner = msg.sender
    self.curr_id = 0

@external
@payable
def create_game(_secret_number:uint256) -> uint256:
    assert msg.value == 10*(10**18), "You should pay 10 ether to create game"
    assert (_secret_number >= 0) and (_secret_number <= 100), "Number should be in the range of 0-100"
    self.game_index[self.curr_id].game_owner = msg.sender
    self.game_index[self.curr_id].secret_number = _secret_number
    self.game_index[self.curr_id].game_balance = self.game_index[self.curr_id].game_balance + msg.value
    self.game_index[self.curr_id].guess_count = 0
    self.game_index[self.curr_id].is_active = True
    self.curr_id = self.curr_id + 1
    return self.curr_id - 1

@external
@view
def get_game_balance(_game_id:uint256) -> uint256:
    return self.game_index[_game_id].game_balance
        
@external
@payable
def play_game(_game_id: uint256, _game_guess: uint256) -> String[100]:
    assert self.game_index[_game_id].is_active == True
    assert msg.value == 1*(10**18), "You must pay 1 ether to play"
    assert msg.sender != self.game_index[_game_id].game_owner

    self.game_index[_game_id].game_balance = self.game_index[_game_id].game_balance + msg.value

    self.game_index[_game_id].guess_count = self.game_index[_game_id].guess_count + 1
    
    if self.game_index[_game_id].secret_number == _game_guess:
        send(msg.sender, (self.game_index[_game_id].game_balance * 99)/100)
        send(self.contract_owner, self.game_index[_game_id].game_balance / 100)
        self.game_index[_game_id].game_balance = 0
        self.game_index[_game_id].is_active = False
        return "Congrats you just got paid"
    elif self.game_index[_game_id].guess_count >= 10:
        self.game_index[_game_id].is_active = False
        send(self.contract_owner, (self.game_index[_game_id].game_balance * 99)/100)
        self.game_index[_game_id].game_balance = 0
        return "That was your last attempt, also the creator of the game won most of the pot"

    return "Keep playing, price still up for grabs"



