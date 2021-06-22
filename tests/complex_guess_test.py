import pytest
from brownie import Wei, accounts, GuessGameComplex

@pytest.fixture
def complex_guess():
    guess_number = GuessGameComplex.deploy({'from':accounts[1]})
    guess_number.create_game(9, {'from':accounts[9],'value':'10 ether'})
    return guess_number

#Can also check the balance of players
def test_wrong_guess(complex_guess):
    assert complex_guess.get_game_status(0) == True
    init_bal = complex_guess.get_game_balance(0)
    init_player_bal = accounts[4].balance()
    complex_guess.play_game(0, 8, {'from':accounts[4], 'value':'1 ether'})
    assert accounts[4].balance() == init_player_bal - Wei('1 ether'), 'The player after guess balance is incorrect'
    after_guess_bal = complex_guess.get_game_balance(0)
    assert after_guess_bal > init_bal
    assert complex_guess.get_game_status(0) == True
    complex_guess.play_game(0, 8, {'from':accounts[5], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[6], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[4], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[4], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[5], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[4], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[5], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[6], 'value':'1 ether'})
    complex_guess.play_game(0, 8, {'from':accounts[6], 'value':'1 ether'})
    assert complex_guess.get_game_balance(0) == 0
    assert complex_guess.get_game_status(0) == False


def test_right_guess(complex_guess):
    assert complex_guess.get_game_status(0) == True
    init_bal = complex_guess.get_game_balance(0)
    pre_player_balance = accounts[3].balance()
    assert init_bal == Wei('10 ether')
    complex_guess.play_game(0, 9, {'from':accounts[3], 'value':'1 ether'})
    assert complex_guess.get_game_status(0) == False
    assert accounts[3].balance() == (pre_player_balance - Wei('1 ether')) + (init_bal + Wei('1 ether')) * 99 /100
    final_bal = complex_guess.get_game_balance(0)
    assert final_bal == 0

