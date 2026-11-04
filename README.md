# 웨딩 촬영 무드보드 — 온라인 편집형

## 무엇이 되나요?
- 관리자만 로그인하여 글, 촬영 정보, 사진, 사진별 코멘트, 섹션을 수정합니다.
- 수정하면 Supabase 데이터베이스에 자동 저장됩니다(약 1초 후).
- 사진은 Supabase Storage에 올라갑니다.
- 스튜디오는 같은 사이트 주소로 접속하여 최신 시안을 보기만 합니다. 로그인 불필요.
- 스튜디오에서 페이지를 열어 놓은 상태에서도 수정 사항이 자동 반영됩니다(Realtime).
- 인쇄 / PDF 저장, JSON 백업 및 복원 가능.

## 1. Supabase 준비 (무료 플랜으로 시작 가능)
1. https://supabase.com 에 가입하고 New project를 생성합니다.
2. 프로젝트의 SQL Editor에서 `supabase-setup.sql` 전체를 실행합니다.
3. Authentication > Users > Add user에서 본인 이메일과 비밀번호로 계정을 만듭니다.
   이메일 자동 확인 옵션이 있으면 확인 처리하거나 받은 메일의 인증을 완료합니다.
4. SQL Editor에서 아래를 실행합니다. 이메일을 방금 만든 계정 이메일로 바꾸세요.

```sql
insert into public.moodboard_admins (user_id)
select id from auth.users where email = '내이메일@example.com'
on conflict do nothing;
```

5. Project Settings > API (또는 Connect)에서 Project URL과 **publishable key / anon public key**를 확인합니다.
6. `config.js`의 두 문자열을 실제 값으로 바꿉니다.
   **service_role / secret key는 절대 넣지 마세요.** 브라우저에 노출됩니다.

## 2. GitHub에 업로드
1. https://github.com 에서 새 repository `wedding-moodboard`를 만듭니다.
2. `index.html`, `config.js`, `supabase-setup.sql`, `README.md`를 업로드하고 Commit changes 합니다.
3. SQL과 README는 공개 저장소에 있어도 괜찮지만, 관리자 이메일/비밀번호를 파일에 적지 마세요.
4. `config.js`에 들어가는 것은 공개용 anon/publishable key만 사용합니다.

## 3. Vercel 배포
1. https://vercel.com/new 에서 GitHub로 로그인합니다.
2. `wedding-moodboard` repository를 Import합니다.
3. Framework Preset: Other / Root Directory: `./` / Build Command: 비워 둡니다.
4. Deploy를 누르면 `https://프로젝트이름.vercel.app` 주소가 만들어집니다.
5. 본인은 사이트 상단에서 관리자 로그인 → 편집합니다.
6. 스튜디오에는 **같은 주소**를 전달합니다. 스튜디오는 로그인하지 않으므로 보기 전용입니다.

## 4. 이용 및 주의사항
- 이름·업체·날짜·작가 코멘트는 클릭하여 수정합니다.
- 사진은 섹션의 '사진 추가'에서 업로드합니다. 업로드된 사진은 공개 URL을 갖습니다.
- 사진 교체·삭제 시 화면에서만 제거되며, 이전 사진 파일은 Storage에 남습니다.
  저장 용량을 정리하려면 Supabase Storage에서 오래된 파일을 수동 삭제하세요.
- 자동 저장 중 탭을 닫지 마세요. '온라인 저장 완료' 상태를 확인하세요.
- PDF는 'PDF 저장 / 인쇄' → 인쇄 대상 'PDF로 저장'을 선택합니다.
- 스튜디오 링크를 아는 사람은 내용을 볼 수 있습니다. **개인정보·비공개 사진이 있으면 공유 범위를 신중히 관리하세요.**
- 데이터와 사진은 Supabase에 저장되며, GitHub/Vercel만으로는 공유 편집이 되지 않습니다.
- 사이트에서 수정한 내용은 Supabase에 남습니다. GitHub의 `index.html` 파일 자체가 바뀌는 것은 아닙니다.
- Supabase 무료 플랜의 제한, 휴면 프로젝트 정책 등은 서비스 정책에 따라 달라질 수 있습니다.

## 문제 해결
- '설정 필요': `config.js`를 수정했는지 확인하세요.
- '관리자로 등록되지 않은 계정': 관리자 이메일과 SQL의 이메일이 일치하는지 확인하세요.
- 사진 업로드 실패: Storage bucket과 policy가 만들어졌는지 확인하세요.
- 수정 후 공유 화면이 갱신되지 않음: 브라우저 새로고침 후 확인하고, SQL의 Realtime publication 설정을 점검하세요.
- SQL 실행 시 policy already exists: 기존 정책이 있는 상태에서 다시 실행한 경우입니다. 새 프로젝트에서 한 번 실행하는 것이 가장 간단합니다.
