import requests
import time

BASE_URL = 'http://127.0.0.1:8000/api/v1'

def run_tests():
    print("🚀 STARTING API TESTS...")
    
    # 1. AUTH (Register & Login)
    print("\n🔐 1. AUTHENTICATION TEST")
    test_user = {'phone': '+998901234567', 'password': 'testpassword123'}
    res = requests.post(f"{BASE_URL}/auth/register/", json=test_user)
    print(f"REGISTER: {res.status_code} - {res.json().get('success')}")
    
    res = requests.post(f"{BASE_URL}/auth/login/", json=test_user)
    print(f"LOGIN: {res.status_code}")
    token = res.json().get('access') if res.status_code == 200 else None
    
    if not token:
        print("❌ Login failed. Cannot proceed with authenticated tests.")
        return

    headers = {'Authorization': f'Bearer {token}'}
    
    # Auth ME
    res = requests.get(f"{BASE_URL}/auth/me/", headers=headers)
    print(f"GET /auth/me/: {res.status_code} - User Phone: {res.json().get('data', {}).get('phone')}")

    # 2. CATEGORIES
    print("\n📦 2. CATEGORIES SETUP")
    # For testing we can just check if endpoint works, categories must be added via admin usually
    # We will skip DB setup for Category and just test Ad without category (null allowed) or create one via API if possible.
    # We made category ReadOnly, so let's just create an Ad with null category first.

    # 3. ADS CRUD
    print("\n🐄 3. ADS API TEST")
    ad_data = {
        "title": "Zo'r sog'in sigir",
        "description": "Kuniga 15 litr sut beradi",
        "price": "15000000",
        "city": "Tashkent",
        "region": "Chilonzor"
    }
    
    # POST
    res = requests.post(f"{BASE_URL}/ads/", json=ad_data, headers=headers)
    print(f"POST /ads/: {res.status_code}")
    ad_id = res.json().get('data', {}).get('id') if res.status_code == 201 else None
    
    if ad_id:
        print(f"✅ Created Ad ID: {ad_id}")
        
        # GET List
        res = requests.get(f"{BASE_URL}/ads/")
        print(f"GET /ads/ list: {res.status_code} - Count: {len(res.json().get('data', {}).get('results', []))}")
        
        # GET Detail (View count test)
        res = requests.get(f"{BASE_URL}/ads/{ad_id}/")
        print(f"GET /ads/{ad_id}/ detail: {res.status_code} - Views: {res.json().get('data', {}).get('views')}")
        res = requests.get(f"{BASE_URL}/ads/{ad_id}/") # View again
        print(f"GET /ads/{ad_id}/ detail again: {res.status_code} - Views: {res.json().get('data', {}).get('views')} (Should be +1)")
        
        # PUT (Edit by owner)
        edit_data = {"title": "Zo'r sog'in sigir (Sotiladi)", "price": "14500000", "city": "Tashkent", "region": "Chilonzor", "description": "Arzonlashdi"}
        res = requests.put(f"{BASE_URL}/ads/{ad_id}/", json=edit_data, headers=headers)
        print(f"PUT /ads/{ad_id}/ (Owner Edit): {res.status_code} - New Title: {res.json().get('data', {}).get('title')}")

        # 4. FILTER TEST
        print("\n🔍 4. FILTER API TEST")
        res = requests.get(f"{BASE_URL}/ads/?city=Tashkent&min_price=10000000")
        print(f"FILTER /ads/?city=Tashkent&min_price=10000000: {res.status_code} - Found: {len(res.json().get('data', {}).get('results', []))}")

        # 5. FAVORITES TEST
        print("\n❤️ 5. FAVORITES API TEST")
        fav_data = {"ad_id": ad_id}
        res = requests.post(f"{BASE_URL}/favorites/", json=fav_data, headers=headers)
        print(f"POST /favorites/: {res.status_code}")
        fav_id = res.json().get('data', {}).get('id') if res.status_code == 201 else None
        
        if fav_id:
            res = requests.get(f"{BASE_URL}/favorites/", headers=headers)
            print(f"GET /favorites/: {res.status_code} - Count: {len(res.json().get('data', {}).get('results', []))}")
            
            res = requests.delete(f"{BASE_URL}/favorites/{fav_id}/", headers=headers)
            print(f"DELETE /favorites/{fav_id}/: {res.status_code}")
        
        # DELETE (Ad)
        res = requests.delete(f"{BASE_URL}/ads/{ad_id}/", headers=headers)
        print(f"DELETE /ads/{ad_id}/: {res.status_code}")
        
    print("\n🎉 ALL TESTS COMPLETED!")

if __name__ == '__main__':
    # Wait for server to be ready
    for _ in range(5):
        try:
            requests.get(BASE_URL + '/ads/')
            break
        except requests.ConnectionError:
            time.sleep(1)
    run_tests()
