package com.aloute.service;

import com.aloute.entity.Friendship;
import com.aloute.entity.Friendship.FriendshipStatus;
import com.aloute.entity.User;
import com.aloute.repository.FriendshipRepository;
import com.aloute.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class FriendshipService {

    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    // 1. Lấy danh sách bạn bè chính thức của một User
    public List<User> getFriends(Long userId) {
        List<Long> friendIds = friendshipRepository.findFriendIdsByUserId(userId);
        if (friendIds.isEmpty()) return Collections.emptyList();
        return userRepository.findAllById(friendIds);
    }

    // 2. Đếm tổng số lượng bạn bè
    public long countFriends(Long userId) {
        return friendshipRepository.countAcceptedFriends(userId);
    }

    // 3. Lấy danh sách lời mời kết bạn gửi đến User
    public List<Friendship> getPendingRequests(Long userId) {
        return friendshipRepository.findByAddresseeIdAndStatusOrderByCreatedAtDesc(userId, FriendshipStatus.PENDING);
    }

    // 4. Tính toán danh sách BẠN CHUNG giữa 2 người
    public List<User> getMutualFriends(Long userId1, Long userId2) {
        if (userId1 == null || userId2 == null || userId1.equals(userId2)) {
            return Collections.emptyList();
        }
        List<Long> friendsOfUser1 = friendshipRepository.findFriendIdsByUserId(userId1);
        List<Long> friendsOfUser2 = friendshipRepository.findFriendIdsByUserId(userId2);

        Set<Long> mutualIds = new HashSet<>(friendsOfUser1);
        mutualIds.retainAll(friendsOfUser2);

        if (mutualIds.isEmpty()) return Collections.emptyList();
        return userRepository.findAllById(mutualIds);
    }

    // 5. Đếm số lượng bạn chung
    public int countMutualFriends(Long userId1, Long userId2) {
        return getMutualFriends(userId1, userId2).size();
    }

    // 6. Gửi lời mời kết bạn & tạo thông báo
    @Transactional
    public void sendFriendRequest(Long requesterId, Long addresseeId) {
        if (requesterId.equals(addresseeId)) return;
        Optional<Friendship> relation = friendshipRepository.findRelationBetween(requesterId, addresseeId);
        if (relation.isEmpty()) {
            User requester = userRepository.findById(requesterId).orElseThrow();
            User addressee = userRepository.findById(addresseeId).orElseThrow();
            Friendship friendship = Friendship.builder()
                    .requester(requester)
                    .addressee(addressee)
                    .status(FriendshipStatus.PENDING)
                    .build();
            friendshipRepository.save(friendship);

            notificationService.createNotification(
                    addressee,
                    requester,
                    requester.getFullName() + " đã gửi cho bạn một lời mời kết bạn.",
                    "/friends?tab=requests"
            );
        }
    }

    // 7. Chấp nhận lời mời kết bạn & tạo thông báo
    @Transactional
    public void acceptRequest(Long friendshipId, Long currentUserId) {
        Friendship friendship = friendshipRepository.findById(friendshipId).orElseThrow();
        if (friendship.getAddressee().getId().equals(currentUserId)) {
            friendship.setStatus(FriendshipStatus.ACCEPTED);
            friendshipRepository.save(friendship);

            notificationService.createNotification(
                    friendship.getRequester(),
                    friendship.getAddressee(),
                    friendship.getAddressee().getFullName() + " đã chấp nhận lời mời kết bạn của bạn.",
                    "/profile?userId=" + friendship.getAddressee().getId()
            );
        }
    }

    // 8. Từ chối / Xóa lời mời theo ID quan hệ
    @Transactional
    public void deleteOrReject(Long friendshipId, Long currentUserId) {
        Friendship friendship = friendshipRepository.findById(friendshipId).orElseThrow();
        if (friendship.getRequester().getId().equals(currentUserId) || friendship.getAddressee().getId().equals(currentUserId)) {
            friendshipRepository.delete(friendship);
        }
    }

    // 9. HỦY KẾT BẠN (Unfriend theo User ID của 2 người)
    @Transactional
    public void unfriend(Long currentUserId, Long targetUserId) {
        Optional<Friendship> relation = friendshipRepository.findRelationBetween(currentUserId, targetUserId);
        relation.ifPresent(friendshipRepository::delete);
    }

    // 10. Tìm kiếm người dùng trong hệ thống
    public List<User> searchUsers(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return Collections.emptyList();
        return userRepository.findByFullNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(keyword.trim(), keyword.trim());
    }

    // 11. Kiểm tra trạng thái quan hệ giữa 2 người
    public String getFriendshipStatus(Long currentUserId, Long targetUserId) {
        if (currentUserId.equals(targetUserId)) return "SELF";
        Optional<Friendship> relation = friendshipRepository.findRelationBetween(currentUserId, targetUserId);
        if (relation.isEmpty()) return "NONE";
        Friendship f = relation.get();
        if (f.getStatus() == FriendshipStatus.ACCEPTED) return "FRIENDS";
        if (f.getStatus() == FriendshipStatus.PENDING) {
            return f.getRequester().getId().equals(currentUserId) ? "SENT" : "RECEIVED";
        }
        return "BLOCKED";
    }
}