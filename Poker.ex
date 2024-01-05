defmodule Poker do

	def deal(list) do
        # Create the two player hands	
		player1 = [Enum.at(list, 0), Enum.at(list, 2)]
		list = list -- player1
		player2 = [Enum.at(list, 0), Enum.at(list, 1)]
		list = list -- player2
		player1 = player1 ++ list	
		player2 = player2 ++ list

		cond do
			checkWinner(checkHand(player1),checkHand(player2)) == "Player1" ->
				player1 = checkHand(player1) -- [Enum.at(checkHand(player1), length(checkHand(player1))-1)]
				Enum.map(player1, &Poker.cardMap/1)
			checkWinner(checkHand(player1),checkHand(player2)) == "Player2" ->
				player2 = checkHand(player2) -- [Enum.at(checkHand(player2), length(checkHand(player2))-1)]
				Enum.map(player2, &Poker.cardMap/1)
			true ->
				false
		end
	end
	
	def checkWinner(list,list2) do
		cond do 
			Enum.at(list, length(list)-1) > Enum.at(list2, length(list2)-1) ->
				"Player1"
			Enum.at(list, length(list)-1) < Enum.at(list2, length(list2)-1) ->
				"Player2"
			true ->
				list = List.delete_at(list, length(list)-1)
				list2 = List.delete_at(list2, length(list2)-1)
				
				list = Enum.sort_by(list, fn x -> rem(x,13) end, :desc)
				list = Enum.sort_by(list,fn x -> rem(x,13) != 0 end)
				list = Enum.sort_by(list, fn x -> rem(x,13) != 1 end)
				
				list2 = Enum.sort_by(list2, fn x -> rem(x,13) end, :desc)
				list2 = Enum.sort_by(list2, fn x -> rem(x,13) != 0 end)
				list2 = Enum.sort_by(list2, fn x-> rem(x,13) != 1 end)
				
				cond do
					rem(Enum.at(list,0),13) == 1 ->
						"Player1"
					rem(Enum.at(list2,0),13) == 1 ->
						"Player2"
					rem(Enum.at(list,0),13) == 0 ->
						"Player1"
					rem(Enum.at(list2,0),13) == 0 ->
						"Player2"
					rem(Enum.at(list,0),13) > rem(Enum.at(list2,0),13) ->
						"Player1"
					rem(Enum.at(list2,0),13) > rem(Enum.at(list,0),13) ->
						"Player2"
					true ->
						cond do
							rem(Enum.at(list,length(list)-1),13) > rem(Enum.at(list2,length(list)-1),13) ->
								"Player1"
							true ->
								"Player2"
						end
				end
		end
	end

	def checkHand(list) do
		cond do
			checkRoyalFlush(list,[]) ->
				checkRoyalFlush(list,[]) ++ [200]
				
			checkStraightFlush(list) ->
				checkStraightFlush(list) ++ [170]
				
			checkFourofaKind(list) ->
				checkFourofaKind(list) ++ [150]
				
			checkFullHouse(list,[]) ->
				checkFullHouse(list,[]) ++ [130]
			
			checkFlush(list) ->
				checkFlush(list) ++ [110]
				
			checkStraight(list) ->
				checkStraight(list) ++ [90]
			
			checkThreeofaKind(list) ->
				checkThreeofaKind(list) ++ [70]
				
			checkTwoPair(list,[]) ->
				checkTwoPair(list,[]) ++ [50]
			
			checkPair(list) ->
				checkPair(list) ++ [30]
				
			true ->
				checkHighCard(list) ++ [10]
		end		

		
	end
	
	def checkRoyalFlush(list, list2) do
		if checkSuit(list) do
			list2 = checkSuit(list)
			if length(checkConsecutive(List.delete_at(checkSuit(list), length(checkSuit(list))-1), [])) == 5 do
				list = checkConsecutive(List.delete_at(checkSuit(list), length(checkSuit(list))-1), [])
				if Enum.at(list, 0) == 14 do       #If the same suit consecutive hand has an ace its a royal flush
					list = Enum.map(list, fn x -> (if x == 14, do: x = 1, else: x = x) end)
					list = list ++ [Enum.at(list2, length(list2) -1)]
					list = listMap(list)
				end
			else
				nil
			end
		else
			nil
		end
	end
	
	def checkStraightFlush(list) do
		 list = if checkSuit(list) do
					if length(checkConsecutive(List.delete_at(checkSuit(list), length(checkSuit(list)) -1), [])) == 5 do
						list = checkConsecutive(List.delete_at(checkSuit(list), length(checkSuit(list))-1), [])
						list = listMap(checkSuit(list))
					end
				end
	end
	
	def checkFourofaKind(list) do
		if length(checkRank(list,[],4)) == 4 do
			checkRank(list,[],4)
		else
			nil
		end
	end
	
	def checkFullHouse(list,list2) do
		cond do
			length(checkRank(list,[],3)) == 3 ->
				list2 = checkRank(list,[],3)
				list = list -- checkRank(list,[],3)
				if length(checkRank(list,[],2)) == 2 do
				list2 = list2 ++ checkRank(list,[],2)
				end
				
			length(checkRank(list,[],2)) == 2 ->
				list2 = checkRank(list,[],2)
				list = list -- checkRank(list,[],2)
				if length(checkRank(list,[],3)) == 3 do
					list2 = list2 ++ checkRank(list,[],3)
				end
			true ->
				false
		end
	end

	def checkFlush(list) do 
		if checkSuit(list) do
			list = checkSuit(list)
			list = List.delete_at(checkSuit(list), length(checkSuit(list))-1)
			list = Enum.sort(list,:desc)
			cond do
				length(list) == 7 ->
					list = list -- [Enum.at(list, length(list)-1)]
					list = list -- [Enum.at(list, length(list)-1)]
				length(list) == 6 ->
					list = list -- [Enum.at(list, length(list)-1)]
				length(list) == 5 ->
					list
				true ->
					false #should not get here unless something goes wrong
			end

		end
	end
	
	def checkStraight(list) do
		if length(checkConsecutive(list,[])) == 5 do
			list = Enum.sort_by(list, fn x -> rem(x,13) end, :desc)
			list = Enum.sort_by(list, fn x -> rem(x,13) != 0 end)
			list = Enum.sort_by(list, fn x -> rem(x,13) != 1 end)
			list = Enum.uniq_by(list, fn x -> rem(x,13) end)
			cond do
				length(list) == 5 ->
					list
				length(list) == 6 ->
					cond do	
						rem(Enum.at(list,0),13) == rem(Enum.at(list,1),13) +1 ->
							list = List.delete_at(list, length(list)-1)
						rem(Enum.at(list,0),13) == 0 and rem(Enum.at(list,1),13) == 12 ->
							list = List.delete_at(list,length(list)-1)
						true ->
							list = List.delete_at(list,0)
					end	
				true ->
					cond do
						rem(Enum.at(list, 0), 13) == 1 and rem(Enum.at(list,1),13) == 0 ->
							list = List.delete_at(list,length(list)-1)
							list = List.delete_at(list,length(list)-1)
						rem(Enum.at(list,0),13) == rem(Enum.at(list,1),13) +1 ->
							list = List.delete_at(list,length(list)-1)
							list = List.delete_at(list,length(list)-1)
						rem(Enum.at(list,0),13) == 0 and rem(Enum.at(list,1),13) == 12 ->
							list = List.delete_at(list,length(list)-1)
							list = List.delete_at(list,length(list)-1)
						rem(Enum.at(list,1),13) == rem(Enum.at(list,2),13) +1 ->	
							list = List.delete_at(list, 0)
							list = List.delete_at(list,length(list) -1)
						true ->
							list = List.delete_at(list, 0)
							list = List.delete_at(list,0)
					end
			true ->
				list = List.delete_at(list, 0)
				list = List.delete_at(list,0)
			end
		end
	end
	
	def checkThreeofaKind(list) do
		if length(checkRank(list,[],3)) == 3 do
			checkRank(list,[],3)
		else
			nil
		end
	end
	
	def checkTwoPair(list,list2) do
		if length(checkRank(list,[],2)) do 
			list2 = checkRank(list,[],2)
			list = list -- checkRank(list,[],2)
			if length(checkRank(list,[],2)) == 2 do
				list2 = list2 ++ checkRank(list,[],2)
			else
				nil
			end
		else
			nil
		end
	end
	
	def checkPair(list) do
		if length(checkRank(list,[],2)) == 2 do
			checkRank(list,[],2)
		end
	end

	def checkHighCard(list) do
		list = Enum.sort_by(list, fn x -> rem(x,13) end, :desc)
		cond do
			rem(Enum.at(list,length(list)-1),13) == 1 ->
				[Enum.at(list,length(list)-1)]
			rem(Enum.at(list,length(list)-2),13) == 1 ->
				[Enum.at(list,length(list)-2)]
			rem(Enum.at(list,length(list)-1),13) == 0 ->
				[Enum.at(list,length(list)-1)]
			true ->
				[Enum.at(list,0)]
		end
	end

	def checkSuit(list) do
		cond do
			Enum.count(list, fn x -> x < 14 end) >= 5 ->
				list = Enum.filter(list, fn x -> x < 14 end)
				list ++ ["C"]
			Enum.count(list, fn x -> x > 13 and x < 27 end) >= 5 ->
				list = Enum.filter(list, fn x -> x > 13 and x < 27 end)
				list ++ ["D"]
			Enum.count(list, fn x -> x > 26 and x < 40 end) >= 5 ->
				list = Enum.filter(list, fn x -> x > 26 and x < 40 end)
				list ++ ["H"]
			Enum.count(list, fn x -> x > 39 and x < 53 end) >= 5 ->
				list = Enum.filter(list, fn x -> x > 39 and x < 53 end)
				list ++ ["S"]
			true -> 
				nil  #should never get here
		end
		
	end
	
	def checkRank(list,list2,num) do
		list = Enum.sort_by(list, fn x -> rem(x,13) end, :desc)
		list = Enum.sort_by(list, fn x -> rem(x,13) != 0 end)
		list = Enum.sort_by(list, fn x -> rem(x,13) != 1 end)
		if (length(list) == 1 or length(list2) == num) do
			list2
		else
			[head | tl] = list
			[hd | _ ] = tl
			
			if rem(head,13) == rem(hd,13) do
				list2 = list2 ++ [head]
				
				list2 = if length(list2) == (num-1) do
							list2 = list2 ++ [hd]
							
						else
							list2
						end
				
				
				checkRank(tl,list2,num)
			else
				checkRank(tl,[],num)
			end
		
		end
	end
	
	def checkConsecutive(list, list2) do
		list = Enum.map(list, fn x -> rem(x,13) end)
		list = Enum.map(list, fn x -> (if x == 1, do: x = 14, else: x = x) end)
		list = Enum.map(list, fn x -> (if x == 0, do: x = 13, else: x = x) end)
		list = Enum.sort(list, :desc)
		list = Enum.uniq(list)
		if length(list2) == 5 or length(list) == 1 do
			list2
		else
			[head | tl] = list
			[hd | _ ] = tl
			if head == (hd+1) do
				list2 = list2 ++ [head]
				
				list2 = if length(list2) == 4 do
							list2 = list2 ++ [hd]
						else
						list2
						end
				
				checkConsecutive(tl,list2)
			else
				checkConsecutive(tl,[])
			end
		end
	end
	
	def listMap(list) do
		cond do
			Enum.at(list, length(list)-1) == "C" ->
				list = List.delete_at(list, length(list)-1)
				list = Enum.map(list, fn x -> x end)
				list
					
			Enum.at(list, length(list)-1) == "D" ->
				list = List.delete_at(list, length(list)-1)
				list = Enum.map(list, fn x -> x + 13 end)
				list
					
			Enum.at(list, length(list)-1) == "H" ->
				list = List.delete_at(list, length(list)-1)
				list = Enum.map(list, fn x -> x + 26 end)
				list
					
			Enum.at(list, length(list)-1) == "S" ->	
				list = List.delete_at(list, length(list)-1)
				list = Enum.map(list, fn x -> x + 39 end)
				list
		end
	end
	
	def cardMap(element) do
		cond do
			element < 13 ->
				Integer.to_string(rem(element,13)) <> "C"
			element > 13 and element < 26 ->
				Integer.to_string(rem(element,13)) <> "D"
			element > 26 and element < 39 ->
				Integer.to_string(rem(element,13)) <> "H"
			element > 39 and element < 52 ->
				Integer.to_string(rem(element,13)) <> "S"
			element == 13 ->
				Integer.to_string(13) <> "C"
			element == 26 ->
				Integer.to_string(13) <> "D"
			element == 39 ->
				Integer.to_string(13) <> "H"
			element == 52 ->
				Integer.to_string(13) <> "S"
		end
	end
	
end