import 'package:loci/features/raffles/data/models/raffle_detail_model.dart';
import 'package:loci/features/raffles/data/models/raffle_list_model.dart';
import 'package:loci/features/raffles/data/repositories/raffles_repository.dart';

/// Domain orchestration for raffles. Controllers call this — never NetworkCaller.
class RafflesService {
  final RafflesRepository _repository;

  RafflesService(this._repository);

  Future<RaffleListResponseModel> getRaffles({
    required int page,
    required int limit,
    String? search,
  }) async {
    final body = await _repository.getRaffles(
      page: page,
      limit: limit,
      search: search,
    );
    return RaffleListResponseModel.fromJson(body);
  }

  Future<RaffleDetailsModel> getRaffleDetails(String raffleId) async {
    final body = await _repository.getRaffleDetails(raffleId);
    return RaffleDetailsModel.fromJson(body);
  }

  Future<RaffleDetailsModel> participateInRaffle(String raffleId) async {
    final body = await _repository.participateInRaffle(raffleId);
    return RaffleDetailsModel.fromJson(body);
  }
}
