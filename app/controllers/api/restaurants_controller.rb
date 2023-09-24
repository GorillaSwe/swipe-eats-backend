class Api::RestaurantsController < ApplicationController
  def index
    client_latitude = params[:latitude]
    client_longitude = params[:longitude]
    category = params[:category]
    radius = params[:radius]
    price_levels = params[:price_levels]

    if client_latitude.blank? || client_longitude.blank?
      render_error(:bad_request, '位置情報が提供されていません')
      return
    end
    
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    # restaurants = client.spots(
    #   client_latitude, client_longitude, 
    #   name: category,
    #   radius: radius, 
    #   types: 'restaurant', 
    #   language: 'ja'
    # )

    # テスト用レストランデータ
    restaurants = [ { "placeId": "ChIJw4pOovBPGmARt7Xes50P5ng", "name": "スプーンフル", "lat": 34.8679226, "lng": 138.2569951, "photoUrl": [ { "url": "https://lh3.googleusercontent.com/places/ANXAkqEOjcyzOa8CPfUrrSnPgwMCwMxkEM_oRW-udiIbn3exzbv-fBuDwyOnNcG_2W6BORFs4OCbfw_aS3dsdyoL6ci_zZJEleI1sDw=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqH3g_GsE8OyTyYIlLTXLxK3CUSl_W5w2O3UVssJUyv_d4c5UMQeN9TKXgkkqgxGxi5lOBMN5vnHk9_FjaA7MA6UBsjnT-6knHM=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqE6-MrrJXYzl2qyYQ-bhTu5t3VcuK4neDADrcgeYMGBvqXOOu_PtJGQEAMZ20U0kgn6-FXPeawyvxFW6SA7RZUHQndjCK2R_eY=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqG_pMOpiMYIpEH6R-NVaIXxxePgQAE7jlwk23ReocrPKoSHh6mPg2EpWRk1Sjxl4kvloJ8BkdyC3t17WVDj2AwhKhTlmVVzXhY=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqEp56BlwOkb7CZbLZFqxgpjL-hotHehisWVXACZjn2ZZPgi8kBCf4BJ5V033YdTNMtkp8UGh9I0ri21l3dz6oOLKakTFRFgRG0=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFjB0bzCxl_s6JJobVpLjsuuAZq6Z-pqRRIRox9QXDwcVcJVxZOT6iZ1iIS7cdVRVKrzEk4y76Les2EPwOzM1NKxRTsWeIKB_Y=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqGx6RcgeHOh8rrzkIBwYp1zK2-MWUS0LT6uJo2hEWBgiwk8YklTE5CAk3FNtzy0PR8B1Ad3cbTdSieCPdYAihPVB8U_hcF1vrM=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFfd1crjtoWGoedne-rOC3f4g7Pw6LjX_wCcAzxBm_wBGJhr22COWmo0B9vOessgCft4xaDiel9ZV6JZ1dYpMjFFoAFNSxlzH8=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqGtB4gI_ogzkaIr3f1cnm4Gd5VpTSGRbAipdIlLPNT6-xqbnnLAb483v2zEf4FJHAybsy5igzGUJ2eRBskla7nxncn04aJoZgs=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqGVWD9UIcF7BmwYCCF_B4AFEtwHd_a_ISUONQapJMOaDu2vdFRuAQq2ioF0R1JRnTEDQEvW0pYmxhH-sFTUxd8OEz4s5uBQlFw=s1600-w800" } ] }, { "placeId": "ChIJBV3OasBPGmARYnMWmWEuaqU", "name": "八兵衛 藤枝本店", "lat": 34.8678764, "lng": 138.2581131, "photoUrl": [ { "url": "https://lh3.googleusercontent.com/places/ANXAkqEqPvm7QYJfU7DIKLG-CpFS1AS-MSjo3M6hpOk98jDI9AJmqlRCRxaw6PdSaPkG2pGosapA1713mkMsBL59WWzIbFyxr3kgntw=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFcOV8oDKu3Gv6gh_y9wlsH__hPDlf_ffgmDyFfruen0wgcpIelIfkcIZS8ymP2iDVeCJq_xhkpnPWCdpFIXYOlRIvrvilpd1U=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqHESW06M9nYiyCFSkcD_YKDit4H2Wi0V1dpZG0kZyWnTrQyoc3gKOWTxhGB9K5UJGl3eauCN_Oju__B2sTRYR4sATI7eyjsMck=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFZuGqVcC0qV3wgpBHxgR4iSwTSI9pp8DP7uUUCpM8f1X2qgsZhIL64jomN5AyYikns19x0sbtO-KEcCPgDjhVmxjTp1dl96G4=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqH14qkS4MD9IJsE3SzBkBZRI37FdwfK163rmXx7sIiwfzDQbka9X5YGjG19HnpATbnGdtZqqkvC5F72rBK_h1w5WZV6RgHCTQM=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFUsObCyzRvKxe7IdLc1cAz4hGXATNQhJEZ9HXN5QjYP8yUzfgVwuiqs_r-MBAUw1KrR5WFiBAapBrBOOloeZ99T1GJ7S3InWU=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqEODKpRJp3vkTQGfLY59lGc5mAEQYUDrkcYcYHKi9WXwFhUytYX7CRyFRDdJKlKc6rmhcuTfL5hEb2cVn-Nto5FbtGnWb3Jcyk=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqEcNiH3pjGOizMSxkeEpidOSCYpGpqCeBgTbKv2eeZvphwdcfTmA9hFKtEN9_Pzjeto2vbAvGkX1bUonE_RtvHi-O6mW3j7nds=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFxcPWcvw8tl5y9QwgiEqQXEJZb_vuObOOXHjxg2YkHokJ_QDVP54q2J4YA3zonROA8bZbk-VyR1DahhBcdfveadDSUBaKMuWk=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqHLSJuYd5tMHYSkfLtUV7tT6SMH04VdVjG3PoTgWPBD1ygAnRa20P4lQE34_l4ZDZHyuUnTotizzAKETPliP-qLrkZOckSc0B8=s1600-w800" } ] }, { "placeId": "ChIJQznqasBPGmARpU5eCtgPlD8", "name": "たろべっち", "lat": 34.8679124, "lng": 138.2581095, "photoUrl": [ { "url": "https://lh3.googleusercontent.com/places/ANXAkqHY7KuWd_jtFWZDILlbNzc72ikRqLtZKIC3lZ6aHaWHhs84k2OcSbJ8UcGf8xyhn9URDlSX1FeQEs80RNK0q77Zeabv_j6AydM=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqHyH3lVNPVH7l7knvnggsu7-3XlfR-kpDzSsIEeASHxT2ohkqP-4PfXKT6v669spC39HUjwglZzHrmNHKkA6xn-KDSfOw9Jdjo=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFq6IMZX-VYT2w3PhyfFXXmoY1x3o9ygP41h0n82Vwb5KL-rITQ1g_d_xZcy9rrEMbQw6-rtmgLFrH3Z_npo_09OznjNFRtBS0=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqHJqeWp8AyBvCp_S92Q7qFqoNKrt-TukOb2qRS7WjtH2zP9oTOK-9P276XTf93XSkFOmcp2Q6ZpFemMvejzEBab3hM1UrEpGTA=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqEonPY0N2PeNczEAkwWeitQxIWyxnezVCyKpymlJle_gaZOudBZJlXtl1VV0p9o17BJtIJiFR0KoAp70tDG1liLR39bZ4-BYtA=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFZuFAxFRDFRAuqtx7w_h90rpdjoiMFbROCR8t1g4VkU9g4AjTzZzu9fPbaWhl3afRHrpfdwETBBJ6J59l8P3BbZyTJsznhlKg=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqFiFCZmxlhZXZi7NzzRHLyC2xYaTrFg9DL4OFTJDjZAyN1YFl9M7cbrlwIXqVO-MuyIwgtgQKX1ZVMKuXGnzrqiTHwY9jBUogY=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqGLeEP3eXH48eIejhOYGgVgZ90lhsmm5OatCIlfTjO8BmM-7sZw76K7_bHwIvL4JXzGjpf4hKxYN3BDr8qx5WZqH7zhTAMZCM8=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqE3I3YCEQ_7FVebmb2ZDHF2MJEHBtRYBkrMbFtBGKES5wamKQDY1RQWeAQ7r5UqGgo0SYp3PYujuuAvW6exCKQT8ao8WLUwSOw=s1600-w800" }, { "url": "https://lh3.googleusercontent.com/places/ANXAkqGVKMgewscOa3T7zaNy3-y764Uhe-W1eUo_mkvzmcZCwrEOxda6M1zCN5VnKHKi7eFG7gQEdtbvLjfrLj7XqjjFilBpe2Zwp6g=s1600-w800" } ] } ]

    if restaurants.blank?
      render_error(:not_found, 'レストランが見つかりません')
      return
    end
    
    # レストラン情報を必要なプロパティに絞り込む
    # simplified_restaurants = restaurants.map do |restaurant|
    #   {
    #     place_id: restaurant.place_id,
    #     name: restaurant.name,
    #     lat: restaurant.lat,
    #     lng: restaurant.lng,
    #     photo_url: photo_url(restaurant),
    #   }
    # end

    # テスト用変数
    simplified_restaurants = restaurants

    render json: { status: 200, message: simplified_restaurants}
  end
  
  def show
    restaurant = Restaurant.find_by(id: params[:id])
    if restaurant
      render json: restaurant
    else
      render json: { error: 'レストランが見つかりません' }, status: :not_found
    end
  end

  def render_error(status, message)
    render json: { error: message }, status: status
  end

  private def photo_url(restaurant)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    restaurant_details = client.spot(restaurant.place_id)
    if restaurant_details.present?
      return restaurant_details.photos.map do |restaurant_photo|
        {
          url: restaurant_photo.fetch_url(800)
        }
      end
    else
      return nil
    end
  end
end