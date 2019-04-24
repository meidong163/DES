import java.security.Key;
import java.security.SecureRandom;
import java.security.spec.AlgorithmParameterSpec;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.IvParameterSpec;

import com.sun.org.apache.xml.internal.security.utils.Base64;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

@SuppressWarnings("restriction")
public class DESDemo {


    public static final String ALGORITHM_DES_EBC = "DES";
    public static final String ALGORITHM_DES_CBC = "DES/CBC/PKCS5Padding";



    /**
     * DES算法，加密
     *
     * @param data
     *            待加密字符串
     * @param key
     *            加密私钥，长度不能够小于8位
     * @return 加密后的字节数组，一般结合Base64编码使用
     *             异常
     */
    public static String encodeEBC(String key, byte[] data) throws Exception {
        try {
            DESKeySpec dks = new DESKeySpec(key.getBytes());
            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES_EBC);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            byte[] bytes = cipher.doFinal(data);
            // return byte2hex(bytes);
            return new String(Base64.encode(bytes));
        } catch (Exception e) {
            throw new Exception(e);
        }
    }

    /**
     * DES算法，解密
     *
     * @param data
     *            待解密字符串
     * @param key
     *            解密私钥，长度不能够小于8位
     * @return 解密后的字节数组
     * @throws Exception
     *             异常
     */
    public static byte[] decodeEBC(String key, byte[] data) throws Exception {
        try {
            DESKeySpec dks = new DESKeySpec(key.getBytes());
            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES_EBC);
            cipher.init(Cipher.DECRYPT_MODE, secretKey);
            return cipher.doFinal(data);
        } catch (Exception e) {
            throw new Exception(e);
        }
    }

    /**
     * DES算法，加密
     *
     * @param data
     *            待加密字符串
     * @param key
     *            加密私钥，长度不能够小于8位
     * @return 加密后的字节数组，一般结合Base64编码使用
     *             异常
     */
    public static String encodeCBC(String key, byte[] data) throws Exception {
        try {
            DESKeySpec dks = new DESKeySpec(key.getBytes());
            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES_CBC);
            IvParameterSpec iv = new IvParameterSpec(key.getBytes());
            AlgorithmParameterSpec paramSpec = iv;
            cipher.init(Cipher.ENCRYPT_MODE, secretKey,paramSpec);
            byte[] bytes = cipher.doFinal(data);
            // return byte2hex(bytes);
            return new String(Base64.encode(bytes));
        } catch (Exception e) {
            throw new Exception(e);
        }
    }

    /**
     * DES算法，解密
     *
     * @param data
     *            待解密字符串
     * @param key
     *            解密私钥，长度不能够小于8位
     * @return 解密后的字节数组
     * @throws Exception
     *             异常
     */
    public static byte[] decodeCBC(String key, byte[] data) throws Exception {
        try {
            DESKeySpec dks = new DESKeySpec(key.getBytes());
            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES_CBC);
            IvParameterSpec iv = new IvParameterSpec(key.getBytes());
            AlgorithmParameterSpec paramSpec = iv;
            cipher.init(Cipher.DECRYPT_MODE, secretKey,paramSpec);
            return cipher.doFinal(data);
        } catch (Exception e) {
            throw new Exception(e);
        }
    }


    /**
     * 获取编码后的值
     * @param data
     * @return
     * @throws Exception
     */
    public static String decodeValue(String data) {
        byte[] datas;
        String value = null;
        try {
            String key  = data.substring(data.length()-8,data.length());
            data = data.substring(0,data.length()-8);
            datas = decodeCBC(key, Base64.decode(data.getBytes()));
            value = new String(datas);
        } catch (Exception e) {
            value = "";
        }
        return value;
    }

    public static void main(String[] args) throws Exception {

//       EBC 模式
        String source = "我爱你中国 中国你好";
        String key = "11111111";
        String enRes = DESDemo.encodeEBC(key,source.getBytes());
        System.out.println("蜜文 "+enRes);

        byte[] datas = Base64.decode(enRes.getBytes());
        byte[] value = DESDemo.decodeEBC(key,datas);
        String fina = new String(value);
        System.out.println("明文 "+fina);

//      CBC 模式
        String enRes1 = DESDemo.encodeCBC(key,source.getBytes());
        System.out.println("蜜文 "+enRes1);

        byte[] datas1= Base64.decode(enRes1.getBytes());
        byte[] value1 = DESDemo.decodeCBC(key,datas1);
        String fina1 = new String(value1);
        System.out.println("明文 "+fina1);
    }
}
