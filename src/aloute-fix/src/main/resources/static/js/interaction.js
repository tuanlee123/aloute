/* ALOUTE - Like & Comment bằng AJAX (Bạn 3 - feature/social-interaction) */
document.addEventListener('DOMContentLoaded', function () {
    'use strict';

    var bars = document.querySelectorAll('.interaction-bar');
    if (!bars.length) return;
    var ctx = bars[0].dataset.ctx || '';

    // ---------- Gọi API, tự chuyển về trang đăng nhập nếu hết phiên ----------
    function api(path, options) {
        var opts = Object.assign({ credentials: 'same-origin', headers: { 'Accept': 'application/json' } }, options || {});
        return fetch(ctx + path, opts).then(function (res) {
            if (res.redirected || res.status === 401) {
                window.location.href = ctx + '/login';
                throw new Error('Chưa đăng nhập');
            }
            if (!res.ok) {
                return res.json().catch(function () { return {}; }).then(function (b) {
                    throw new Error(b.message || 'Có lỗi xảy ra, vui lòng thử lại!');
                });
            }
            return res.json();
        });
    }

    function barOf(postId) { return document.querySelector('.interaction-bar[data-post-id="' + postId + '"]'); }
    function sectionOf(postId) { return document.querySelector('.comment-section[data-post-id="' + postId + '"]'); }

    // ---------- Hiển thị trạng thái Like ----------
    function renderLike(bar, liked, count) {
        var btn = bar.querySelector('.btn-like');
        var icon = btn.querySelector('i');
        bar.querySelector('.like-count').textContent = count;
        btn.classList.toggle('text-danger', liked);
        btn.classList.toggle('fw-semibold', liked);
        icon.classList.toggle('bi-heart-fill', liked);
        icon.classList.toggle('bi-heart', !liked);
        btn.dataset.liked = liked ? '1' : '0';
    }

    // ---------- Tạo 1 dòng bình luận (dùng textContent để chống XSS) ----------
    function buildComment(c) {
        var row = document.createElement('div');
        row.className = 'd-flex align-items-start gap-2';

        var img = document.createElement('img');
        img.src = c.avatar;
        img.width = 32; img.height = 32;
        img.className = 'rounded-circle border';
        img.style.objectFit = 'cover';

        var box = document.createElement('div');
        box.className = 'bg-light rounded-3 px-3 py-2';
        box.style.maxWidth = '100%';
        box.style.wordBreak = 'break-word';

        var name = document.createElement('div');
        name.className = 'fw-semibold small';
        name.textContent = c.fullName;

        var text = document.createElement('div');
        text.className = 'small';
        text.style.whiteSpace = 'pre-wrap';
        text.textContent = c.content;

        var time = document.createElement('div');
        time.className = 'text-muted';
        time.style.fontSize = '11px';
        time.textContent = c.createdAt;

        box.appendChild(name); box.appendChild(text); box.appendChild(time);
        row.appendChild(img); row.appendChild(box);
        return row;
    }

    function showError(section, msg) {
        var el = section.querySelector('.comment-error');
        el.textContent = msg || '';
        el.classList.toggle('d-none', !msg);
    }

    // ---------- Nạp số like / comment cho tất cả bài trên trang ----------
    var ids = Array.prototype.map.call(bars, function (b) { return b.dataset.postId; });
    api('/api/posts/stats?ids=' + ids.join(',')).then(function (stats) {
        ids.forEach(function (id) {
            var s = stats[id];
            if (!s) return;
            var bar = barOf(id);
            renderLike(bar, s.liked, s.likeCount);
            bar.querySelector('.comment-count').textContent = s.commentCount;
        });
    }).catch(function () { /* giữ nguyên số 0 nếu lỗi */ });

    // ---------- Gửi bình luận ----------
    function sendComment(postId) {
        var section = sectionOf(postId);
        var input = section.querySelector('.comment-input');
        var content = input.value.trim();
        if (!content) return;

        var sendBtn = section.querySelector('.btn-comment-send');
        sendBtn.disabled = true;
        showError(section, '');

        api('/api/posts/' + postId + '/comments', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
            body: JSON.stringify({ content: content })
        }).then(function (data) {
            section.querySelector('.comment-list').appendChild(buildComment(data.comment));
            barOf(postId).querySelector('.comment-count').textContent = data.commentCount;
            input.value = '';
        }).catch(function (e) {
            showError(section, e.message);
        }).finally(function () {
            sendBtn.disabled = false;
            input.focus();
        });
    }

    // ---------- Mở / đóng khung bình luận (lần đầu mở mới tải danh sách) ----------
    function toggleComments(postId) {
        var section = sectionOf(postId);
        section.classList.toggle('d-none');
        if (section.classList.contains('d-none') || section.dataset.loaded === '1') return;

        api('/api/posts/' + postId + '/comments').then(function (list) {
            var box = section.querySelector('.comment-list');
            box.innerHTML = '';
            list.forEach(function (c) { box.appendChild(buildComment(c)); });
            section.dataset.loaded = '1';
        }).catch(function (e) { showError(section, e.message); });
    }

    // ---------- Bắt sự kiện bằng event delegation ----------
    document.addEventListener('click', function (ev) {
        var likeBtn = ev.target.closest('.btn-like');
        if (likeBtn) {
            var bar = likeBtn.closest('.interaction-bar');
            likeBtn.disabled = true;
            api('/api/posts/' + bar.dataset.postId + '/like', { method: 'POST' })
                .then(function (d) { renderLike(bar, d.liked, d.likeCount); })
                .catch(function (e) { console.error(e); })
                .finally(function () { likeBtn.disabled = false; });
            return;
        }
        var cmtBtn = ev.target.closest('.btn-comment-toggle');
        if (cmtBtn) {
            toggleComments(cmtBtn.closest('.interaction-bar').dataset.postId);
            return;
        }
        var sendBtn = ev.target.closest('.btn-comment-send');
        if (sendBtn) {
            sendComment(sendBtn.closest('.comment-section').dataset.postId);
        }
    });

    document.addEventListener('keydown', function (ev) {
        if (ev.key === 'Enter' && ev.target.classList.contains('comment-input')) {
            ev.preventDefault();
            sendComment(ev.target.closest('.comment-section').dataset.postId);
        }
    });
});
