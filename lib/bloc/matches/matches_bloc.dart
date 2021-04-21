import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test2/repositories/matchesRepository.dart';
import 'package:meta/meta.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  
  MatchesRepository _matchesRepository;

  MatchesBloc({@required MatchesRepository matchesRepository})
      : assert(matchesRepository != null),
        _matchesRepository = matchesRepository, super(LoadingState());
  
  @override
  MatchesState get initialState => LoadingState();
        
  

  @override
  Stream<MatchesState> mapEventToState(
    MatchesEvent event,
  ) async* {
    if(event is LoadListsEvent){
      yield* _mapLoadListToState(currentUserId: event.userId);

      }
    if(event is DeleteUserEvent)
      {
        yield* _mapDeleteToState(currentUserId: event.currentUser, selectedUserId: event.selectedUser);
      }
    if(event is OpenChatEvent)
      {
        yield* _mapOpenChatToState(currentUserId: event.currentUser, selectedUserId: event.selectedUser);
      }
    if(event is AcceptUserEvent)
      {
        yield* _mapAcceptUserToState(currentUserId: event.currentUser, selectedUserId: event.selectedUser,
        currentUserName: event.currentUserName,
        currentUserPhotoUrl: event.currentUserPhotoUrl,
        selectedUserName: event.selectedUserName, selectedUserPhotoUrl: event.selectedUserPhotoUrl);
      }
      }

      Stream<MatchesState> _mapLoadListToState({String currentUserId}) async*
      {
        yield LoadingState();

       Stream<QuerySnapshot> matchedList = _matchesRepository.getMatchedList(currentUserId);
       Stream<QuerySnapshot> selectedList = _matchesRepository.getSelectedList(currentUserId);

       yield LoadUserState(matchedList: matchedList, selectedList: selectedList);
      }

      Stream<MatchesState> _mapDeleteToState({String currentUserId, String selectedUserId}) async*
      {
        _matchesRepository.deleteUser(currentUserId, selectedUserId);
      }

      Stream<MatchesState> _mapOpenChatToState({String currentUserId, String selectedUserId}) async*
      {
        _matchesRepository.openChat(currentUserId: currentUserId,selectedUserId: selectedUserId);
      }

      Stream<MatchesState> _mapAcceptUserToState({String currentUserId, String selectedUserId, String currentUserName,
      String currentUserPhotoUrl, String selectedUserName, String selectedUserPhotoUrl})
      async*
      {
       await _matchesRepository.selectUser(currentUserId, selectedUserId, currentUserName,
            currentUserPhotoUrl, selectedUserName, selectedUserPhotoUrl);
      }

}
