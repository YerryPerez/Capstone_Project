part of 'matches_bloc.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object> get props => [];
}

class LoadingState extends MatchesState {}

class LoadUserState extends MatchesState {
  final Stream<QuerySnapshot> matchedList;
  final Stream<QuerySnapshot> selectedList;
  final Stream<QuerySnapshot> pendingList;

  LoadUserState({this.matchedList, this.selectedList, this.pendingList});

  @override
  List<Object> get props => [matchedList,selectedList,pendingList];
}



